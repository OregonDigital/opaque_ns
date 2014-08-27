#!/bin/bash
# Backs up a file and pretty-prints the JSON using a simple python script
set -o nounset
set -o errexit

usage() {
  echo "Usage: ./clean_json.sh <jsonld filename>"
}

cleanup() {
  if [[ -e ${TMPFILE:-} ]]; then
    rm $TMPFILE
  fi
}

# Make sure we fry the tempfile on exit
trap 'cleanup' EXIT

# Get the command-line arg
FILE=${1:-}

if [[ -z $FILE ]]; then
  usage
  exit 1
fi

if [[ ! -e $FILE ]]; then
  echo "File '$FILE' not found"
  echo
  usage
  exit 1
fi

# Make a temp file so we don't obliterate the real file on errors
TMPFILE=`mktemp --suffix=.jsonld cleanup-json-XXXXXX`

# Figure out the python command to run
PYTHONCMD=`which python`
CMD="$PYTHONCMD ./json_cleaner.py $FILE"

# Allow errors here so we can still process other stuff if necessary
set +o errexit
$CMD > $TMPFILE
set -o errexit

if [[ ! -s $TMPFILE ]]; then
  echo
  echo "File unchanged - correct JSON errors and try again"
  exit 1
fi

sed -i -e "s/\s\+$//" $TMPFILE
cp $TMPFILE $FILE
echo "File validated and whitespace corrected"
