#!/bin/bash

set -eu

APP_SHARE=$APP_HOME/share

_log()
{
    echo 1>&2 ">>> $@"
}

run_test()
{
    local test_num="$1"

    # define path
    local home="$APP_SHARE/test/$test_num"
    local file_input="$home/sentences"
    local dir_cache="$home/cache"

    # check path
    if [ ! -d $home ]; then
        echo 1>&2 "$home is not found."
        return 1
    fi
    if [ ! -f $file_input ]; then
        echo 1>&2 "$file_input is not found."
        return 2
    fi
    if [ -d $dir_cache ]; then
        rm -rf $dir_cache
    fi
    mkdir $dir_cache

    _log "tokenize"
    cat $file_input | sed -f en/tokenizer.sed > $dir_cache/sentences.tok

    _log "candc"
    $CCG2LAMBDA_HOME/parsers/candc-1.00/bin/candc \
        --models $CCG2LAMBDA_HOME/parsers/candc-1.00/models \
        --candc-printer xml \
        --input $dir_cache/sentences.tok \
        > $dir_cache/sentences.candc.xml

    _log "candc2transccg"
    python en/candc2transccg.py \
        $dir_cache/sentences.candc.xml \
        > $dir_cache/sentences.xml

    _log "semparse"
    python scripts/semparse.py \
        $dir_cache/sentences.xml \
        en/semantic_templates_en_emnlp2015.yaml \
        $dir_cache/sentences.sem.xml

    _log "prove"
    python scripts/prove.py \
        $dir_cache/sentences.sem.xml \
        --graph_out $dir_cache/graphdebug.html

    _log "visualize"
    python scripts/visualize.py \
        $dir_cache/sentences.xml \
        > $dir_cache/sentences.html
}

case $1 in
    "test")
        run_test "$2"
        ;;
    *)
        help
        ;;
esac
