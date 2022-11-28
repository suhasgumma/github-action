#!/bin/sh

set -e

if [ ! -z "$INPUT_FRAMEWORKS" ] && [ ! -z "$INPUT_CONTROLS" ]; then
echo "Framework and Control is specified. Please specify either one of them or neither"
exit 1
fi

# Split the controls by comma and concatenate with quotes around each control
if [ ! -z "$INPUT_CONTROLS" ]; then
    CONTROLS=""
    set -f; IFS=','
    set -- $INPUT_CONTROLS
    set +f; unset IFS
    for control in "$@"
    do
        control=$(echo $control | xargs) # Remove leading/trailing whitespaces
        CONTROLS="$CONTROLS\"$control\","
    done
    CONTROLS=$(echo "${CONTROLS%?}")
fi

# Subcommands
ARTIFACTS_PATH="/home/ks/.kubescape"
FRAMEWORKS_CMD=$([ ! -z "$INPUT_FRAMEWORKS" ] && echo "framework $INPUT_FRAMEWORKS" || echo "")
CONTROLS_CMD=$([ ! -z "$INPUT_CONTROLS" ] && echo control $CONTROLS || echo "")

# Files to scan
FILES=$([ ! -z "$INPUT_FILES" ] && echo "$INPUT_FILES" || echo .)

# Output file name
OUTPUT_FILE=$([ ! -z "$INPUT_OUTPUTFILE" ] && echo "$INPUT_OUTPUTFILE" || echo "results.out")

# Command-line options
ACCOUNT_OPT=$([ ! -z "$INPUT_ACCOUNT" ] && echo --account $INPUT_ACCOUNT --submit || echo "")

FAIL_THRESHOLD_OPT=$([ ! -z "$INPUT_FAILEDTHRESHOLD" ] && echo --fail-threshold $INPUT_FAILEDTHRESHOLD || echo "")
SEVERITY_THRESHOLD_OPT=$([ ! -z "$INPUT_SEVERITYTHRESHOLD" ] && echo --severity-threshold $INPUT_SEVERITYTHRESHOLD || echo "")

COMMAND="kubescape scan $FRAMEWORKS_CMD $CONTROLS_CMD $FILES --format json --format-version v2 --output output.json  --use-artifacts-from $ARTIFACTS_PATH && yes | kubescape fix output.json && rm output.json"

eval $COMMAND

