#!/bin/sh

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

AST_SOURCERY_CONFIG="${SCRIPT_DIR}/../Sources/ilox/AST/expressions.sourcery.yml"
sourcery --config $AST_SOURCERY_CONFIG
