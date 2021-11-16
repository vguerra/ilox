#!/bin/sh

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

EXPR_SOURCERY_CONFIG="${SCRIPT_DIR}/../Sources/ilox/AST/expressions.sourcery.yml"
STMT_SOURCERY_CONFIG="${SCRIPT_DIR}/../Sources/ilox/AST/statements.sourcery.yml"
sourcery --config $EXPR_SOURCERY_CONFIG
sourcery --config $STMT_SOURCERY_CONFIG
