FROM openjdk:8-jdk-stretch AS build-env

RUN apt-get update && \
    apt-get install -y ant

WORKDIR /build
RUN git clone https://github.com/uwnlp/EasySRL && \
    cd EasySRL && \
    ant

WORKDIR /build
RUN git clone https://github.com/mikelewis0/easyccg

ADD https://github.com/mynlp/jigg/archive/v-0.4.tar.gz /build/v-0.4.tar.gz
RUN tar xzf v-0.4.tar.gz



FROM python:3.6.3-jessie

MAINTAINER Masashi Yoshikawa <yoshikawa.masashi.yh8@is.naist.jp>

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# Install ccg2lambda specific dependencies
RUN sed -i -s '/debian jessie-updates main/d' /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian jessie-backports main" >> /etc/apt/sources.list && \
    echo "Acquire::Check-Valid-Until false;" >/etc/apt/apt.conf.d/10-nocheckvalid && \
    echo 'Package: *\nPin: origin "archive.debian.org"\nPin-Priority: 500' >/etc/apt/preferences.d/10-archive-pi && \
    apt-get update && \
    apt-get install -y openjdk-8-jre && \
    apt-get update --fix-missing && \
    apt-get install -y \
        bc \
        coq=8.4pl4dfsg-1 \
        libxml2-dev \
        libxslt1-dev \
        vim && \
    rm -rf /var/lib/apt/lists/* && \
    pip install -U pip && \
    pip install lxml simplejson pyyaml -I nltk==3.0.5 cython numpy chainer==4.0.0 && \
    python -c "import nltk; nltk.download('wordnet')"

WORKDIR /opt/ccg2lambda
ADD . /opt/ccg2lambda

# Install C&C
# candc-linux-1.00
WORKDIR /opt/ccg2lambda/parsers
RUN /opt/ccg2lambda/wget-from-gdrive.sh \
		1MAqE0RmAC1sOW6A9ErpQcFmFbzD66i7x \
		/opt/ccg2lambda/parsers/candc-linux-1.00.tgz \
	&& tar xvf candc-linux-1.00.tgz
# models-1.02
WORKDIR /opt/ccg2lambda/parsers/candc-1.00
RUN /opt/ccg2lambda/wget-from-gdrive.sh \
		1LR6h3rX7a4Dq7fV_bc2mEmeYxteSyenH \
		/opt/ccg2lambda/parsers/candc-1.00/models-1.02.tgz \
	&& tar xvf models-1.02.tgz \
    && echo "/opt/ccg2lambda/parsers/candc-1.00" >> /opt/ccg2lambda/en/candc_location.txt \
    && echo "candc:/opt/ccg2lambda/parsers/candc-1.00" >> /opt/ccg2lambda/en/parser_location.txt

# Install easyccg
WORKDIR /opt/ccg2lambda/parsers/easyccg
COPY --from=build-env /build/easyccg/easyccg.jar /opt/ccg2lambda/parsers/easyccg/easyccg.jar
RUN /opt/ccg2lambda/wget-from-gdrive.sh \
		0B7AY6PGZ8lc-dUN4SDcxWkczM2M \
		/opt/ccg2lambda/parsers/easyccg/model.tar.gz \
	&& tar xvf model.tar.gz \
    && echo "easyccg:"`pwd` >> /opt/ccg2lambda/en/parser_location.txt

# Install EasySRL
WORKDIR /opt/ccg2lambda/parsers/EasySRL
COPY --from=build-env /build/EasySRL/easysrl.jar /opt/ccg2lambda/parsers/EasySRL/easysrl.jar
RUN /opt/ccg2lambda/wget-from-gdrive.sh \
		0B7AY6PGZ8lc-R1E3aTA5WG54bWM \
		/opt/ccg2lambda/parsers/EasySRL/model.tar.gz \
	&& tar xvf model.tar.gz \
	&& echo "easysrl:/opt/ccg2lambda/parsers/EasySRL/" >> /opt/ccg2lambda/en/parser_location.txt

# Install Jigg
COPY --from=build-env /build/jigg-v-0.4/jar/jigg-0.4.jar /opt/ccg2lambda/parsers/jigg-v-0.4/jar/jigg-0.4.jar
ADD https://github.com/mynlp/jigg/releases/download/v-0.4/ccg-models-0.4.jar /opt/ccg2lambda/parsers/jigg-v-0.4/jar/
RUN echo "/opt/ccg2lambda/parsers/jigg-v-0.4" > /opt/ccg2lambda/ja/jigg_location.txt && \
    echo "jigg:/opt/ccg2lambda/parsers/jigg-v-0.4" >> /opt/ccg2lambda/ja/parser_location_ja.txt

# Install depccg
RUN pip install depccg && \
    python -m depccg en download && \
    python -m depccg ja download && \
    echo "depccg:" >> /opt/ccg2lambda/en/parser_location.txt && \
    echo "depccg:" >> /opt/ccg2lambda/ja/parser_location_ja.txt

WORKDIR /opt/ccg2lambda
RUN cp ./en/coqlib_sick.v ./coqlib.v && coqc coqlib.v && \
    cp ./en/tactics_coq_sick.txt ./tactics_coq.txt
# CMD ["en/rte_en_mp_any.sh", "en/sample_en.txt", "en/semantic_templates_en_emnlp2015.yaml"]
ENTRYPOINT ["/bin/bash"]

