#!/bin/sh

set -eu

cp en/parser_location.txt /tmp
git add *
git commit -m "A"
git checkout emnlp2017_sts
cp /tmp/parser_location en
cat en/parser_location

./en/download_dependencies.sh
pip install -r requirements.txt

wget https://github.com/mynlp/ccg2lambda/files/1172401/models.zip
unzip -d en models.zip

./en/emnlp2017exp.sh 10 en/semantic_templates_en_event_sts.yaml

