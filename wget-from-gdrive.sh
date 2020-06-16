FILE_ID="$1"
PATH_OUTPUT="$2"

PATH_COOKIE=/tmp/cookie

if [ -z "$FILE_ID" ]; then
    echo "FILE_ID is blank."
    exit 1
fi
if [ -z "$PATH_OUTPUT" ]; then
    echo "PATH_OUTPUT is blank."
    exit 1
fi

rm -f $PATH_COOKIE

URL="https://docs.google.com/uc?export=download&id=$FILE_ID"
OPT="-O $PATH_OUTPUT"

wget --quiet --save-cookies $PATH_COOKIE --keep-session-cookies --no-check-certificate $URL

CODE="$(awk '/_warning_/ {print $NF}' /tmp/cookie)"

echo "CODE: [$CODE]"

if [ -n "$CODE" ]; then
    URL="$URL&confirm=$CODE"
    OPT="$OPT --load-cookies $PATH_COOKIE"
fi

echo "URL: $URL"
echo "OPT: $OPT"

wget $OPT $URL

