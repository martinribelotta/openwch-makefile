#!/bin/sh
set -e
P="$0"
F=$(realpath "$P")
B=$(dirname "$F")

TEMPLATE_PATH=$B/template

usage () {
    echo "$P [--cpp] PROJECTNAME"
    echo "$P --help"
    exit 1
}

make_project () {
    NAME="$1"
    P_PATH="${B:?}/$NAME"
    rm -fr "${P_PATH}"
    mkdir -p "${P_PATH}"
    cp -fr "${TEMPLATE_PATH}/"* "${P_PATH}"
    exit 0
}

if [ $# -eq 0 ]; then
    usage
fi

while [ $# -gt 0 ]; do
    case "${1}" in
        --cpp)
            TEMPLATE_PATH=$B/template_cpp
            shift
            if [ $# -gt 0 ]; then
                make_project "${1}"
            else
                usage
            fi
        ;;
        --help)
            usage
        ;;
        *)
            make_project "${1}"
        ;;
    esac
done
