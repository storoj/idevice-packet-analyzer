#!/bin/bash

file=/tmp/hex_plist.log

if [ -z "$1" ]; then
    echo "usage: prettify.sh FILE"
    exit 1
fi

function printInfo {
    dataDelimiter="+------------------------------------------------------------------------+"

    echo $dataDelimiter
    echo $1
    echo $dataDelimiter
}

# $1 is class
# $2 is title
function beginHTMLBlock {
    echo "<div class=\"data $1\"><p class=\"title\">$2</p><pre>"
}

function endHTMLBlock {
    echo "</pre></div>"
}

function htmlencode {
    perl -MHTML::Entities -pe 'encode_entities($_)' $1
}


bin_file=$1

bin_file="/tmp/hex.log.bin"
plist_file=$bin_file".bplist"
rm -rf $plist_file
# file=/tmp/hex_no_plist.log


bytesBeforePlist=-1
plistDescription=""
grep -q '<\?xml' $bin_file

if [ $? -eq 0 ]; then
    bytesBeforePlist=$(grep -oEa "^(.*)<\?xml" $bin_file | wc -c)
    # minus length of "<?xml"
    bytesBeforePlist=$((bytesBeforePlist-5))

    plistDescription="PLAIN-TEXT PLIST"
    tail -c +$bytesBeforePlist $bin_file > $plist_file
else
    # if plain-text plist not found then look for binary one
    grep -q 'bplist00' $bin_file
    if [ $? -eq 0 ]; then
        bytesBeforePlist=$(grep -oEa "^(.*)bplist00" $bin_file | wc -c)
        # minus length of "<?xml"
        bytesBeforePlist=$((bytesBeforePlist-9))

        plistOffset=$((bytesBeforePlist+1))

        plistDescription="BINARY PLIST"
        tail -c +$plistOffset $bin_file > $plist_file

        plutil -convert xml1 $plist_file
    fi
fi

if [ $bytesBeforePlist -eq -1 ]; then
    beginHTMLBlock "raw" "Raw Data"
    xxd -g 1 $bin_file -
    endHTMLBlock
else
    if [ $bytesBeforePlist -gt 0 ]; then
        # get first binary bytes
        beginHTMLBlock "binary-header" "starts with $bytesBeforePlist bytes header"
        head -c $bytesBeforePlist $bin_file | xxd -g 1 - -
        endHTMLBlock
    fi
    beginHTMLBlock "plist" "$plistDescription"
    htmlencode $plist_file
    endHTMLBlock
    # remove temporary plist file
    # rm $plist_file

fi
