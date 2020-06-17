#!/bin/bash

APP_SHARE=$APP_HOME/share

run_test()
{
    local test_num="$1"

    # define path
    local dir_test="$APP_SHARE/test/$test_num"
    local file_input="$dir_test/sentences"

    # check path
    if [ ! -d $dir_test ]; then
        echo 1>&2 "$dir_test is not found."
        return 1
    fi
    if [ ! -f $file_input ]; then
        echo 1>&2 "$file_input is not found."
        return 2
    fi

    cat $file_input | sed -f en/tokenizer.sed > $dir_test/sentences.tok

    $CCG2LAMBDA_HOME/parsers/candc-1.00/bin/candc \
        --models $CCG2LAMBDA_HOME/parsers/candc-1.00/models \
        --candc-printer xml \
        --input $dir_test/sentences.tok \
        > $dir_test/sentences.candc.xml

    python en/candc2transccg.py \
        $dir_test/sentences.candc.xml \
        > $dir_test/sentences.xml
}

case $1 in
    "test")
        run_test "$2"
        ;;
    *)
        help
        ;;
esac
