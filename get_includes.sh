#!/usr/bin/env bash

set -Eeu

INCLUDE_PATH="${1}"
TMP_FILE="$(mktemp)"
trap "rm -f ${TMP_FILE}" INT TERM ERR EXIT

if ! [[ -f ${TMP_FILE} ]]; then
    echo "Temp file ${TMP_FILE} does not exist. Exiting."
    exit 1
fi

if ! [[ -s ${INCLUDE_PATH} ]]; then
    echo "Include path ${INCLUDE_PATH} does not exist. Exiting."
    exit 1
fi

get_include ()
{
    if [[ -s ${1} ]] && ! grep -q "${1}" "${TMP_FILE}"; then
        echo ${1} >> ${TMP_FILE};
    fi
    for include in $(grep -o "^#include <.*/.*>" ${1} | sed "s@^#include <\(.*/.*\)>@${INCLUDE_PATH}/\1@"); do
        if [[ -s ${include} ]] && ! grep -q "${include}" "${TMP_FILE}"; then
            echo ${include} >> ${TMP_FILE};
            get_include ${include}
        fi
    done
}

get_include ${INCLUDE_PATH}/range/v3/range/concepts.hpp
get_include ${INCLUDE_PATH}/range/v3/utility/common_tuple.hpp
get_include ${INCLUDE_PATH}/range/v3/view/chunk.hpp
get_include ${INCLUDE_PATH}/range/v3/view/join.hpp
get_include ${INCLUDE_PATH}/range/v3/range/conversion.hpp
get_include ${INCLUDE_PATH}/range/v3/view/zip.hpp
get_include ${INCLUDE_PATH}/range/v3/range_fwd.hpp
get_include ${INCLUDE_PATH}/range/v3/view/sliding.hpp
get_include ${INCLUDE_PATH}/range/v3/view/take.hpp

sort -o ${TMP_FILE} ${TMP_FILE}
comm -23 - ${TMP_FILE} <<<$(find ${INCLUDE_PATH} -type f | sort)
