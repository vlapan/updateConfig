#!/usr/bin/env bash

testcase() {
  set -e
  local TESTNAME="$1"
  local DATA=""
  if [ -t 0 ]; then
    DATA="$2"
  else 
    DATA="$(cat -)"
  fi
  declare -A ARR=( ["INPUT"]="" ["DATA"]="" ["EXPECTED OUTPUT"]="" ["EXPECTED LOG"]="" )
  RE="([ "$'\t'"]{0,})--- ([A-Z ]+) ---"
  CURRENT_KEY=""
  INDENT=""
  while IFS= read -r LINE; do
    if [[ $LINE =~ $RE ]]; then
      INDENT="${BASH_REMATCH[1]}"
      CURRENT_KEY="${BASH_REMATCH[2]}"
    else
      LINE="${LINE#"${INDENT}"}"
      if [ "${ARR[$CURRENT_KEY]}" ]; then
        ARR[$CURRENT_KEY]="${ARR[$CURRENT_KEY]}"$'\n'"${LINE}"
      else
        ARR[$CURRENT_KEY]="$LINE"
      fi
    fi
  done <<< "$DATA"
  echo -n "${TESTNAME}... "
  TMPFILE=$(mktemp -t updateConfig)
  echo -n "${ARR['DATA']}" > "$TMPFILE"
  if LOG=$(echo "${ARR['INPUT']}" | updateConfig "$TMPFILE" 2>&1) &&
     LOG="${LOG//${TMPFILE}/"/path/to/file.conf"}" &&
     [ -z "${ARR["EXPECTED LOG"]}" ] || [ "$LOG" = "${ARR["EXPECTED LOG"]}" ] &&
     diff <(echo "${ARR["EXPECTED OUTPUT"]}") "$TMPFILE" > /dev/null >&2; then
    echo PASSED
    CODE=0
  else
    echo FAILED
    echo "--- INPUT ---"
    echo "${ARR["INPUT"]}"
    echo "--- DATA ---"
    echo "${ARR["DATA"]}"
    echo "--- EXPECTED OUTPUT ---"
    echo "${ARR["EXPECTED OUTPUT"]}"
    echo "--- ACTUAL OUTPUT ---"
    echo "$(cat "$TMPFILE")"
    echo "--- EXPECTED LOG ---"
    echo "${ARR["EXPECTED LOG"]}"
    echo "--- LOG ---"
    echo "${LOG}"
    CODE=1
  fi
  rm "$TMPFILE"
  return $CODE
}
