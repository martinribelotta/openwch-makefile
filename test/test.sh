#!/usr/bin/env sh
F=$(realpath "$0")
B=$(dirname "$F")
SRC=$(realpath "$B/..")
TESTS=$B/TESTS.txt
N=128
(
while IFS= read -r line
do
    if test "$line" = "${line#\#}"; then
        echo "************************************ $line"
        make --no-print-directory -C "$SRC" clean
        make --no-print-directory -C "$SRC" "-j$N" VERBOSE=n EXAMPLE="$line" all || exit
        make --no-print-directory -C "$SRC" clean
    else
        echo "************************************ Skip: $line"
    fi

done < "$TESTS"
) | tee "$B"/test.log