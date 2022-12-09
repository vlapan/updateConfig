updateConfig() {
  set -e

  local FILENAME="$1"
  if [ -z "$FILENAME" ]; then
    echo "error: file argument should not be empty" >&2
    return 1
  fi
  local DIRNAME
  DIRNAME="$(dirname "$FILENAME")"
  if [ ! -d "$DIRNAME" ]; then
    echo "error: directory should exist" >&2
    return 1
  fi
  if [ ! -r "$DIRNAME" ] || [ ! -w "$DIRNAME" ]; then
    echo "error: directory should be readable and writable" >&2
    return 1
  fi
  if [ ! -f "$FILENAME" ]; then
    echo "error: file should exists" >&2
    return 1
  fi
  if [ ! -r "$FILENAME" ] || [ ! -w "$FILENAME" ]; then
    echo "error: file should be readable and writable" >&2
    return 1
  fi
  if [ -f "$FILENAME.bak" ] && { [ ! -r "$FILENAME.bak" ] || [ ! -w "$FILENAME.bak" ]; }; then
    echo "error: temp file exists but it's not readable/writable" >&2
    return 1
  fi

  local VALUE=""
  if [ -t 0 ]; then
    VALUE="$2"
  else
    VALUE="$(cat -)"
  fi
  if [ -z "$VALUE" ]; then
    echo "error: no value" >&2
    return 1
  fi

  cp -pf "$FILENAME" "$FILENAME.bak"
  awk -v "uncomment=${UPDATECONFIG_UNCOMMENT:-1}" -v "indent=${UPDATECONFIG_INDENT:-4}" -f updateConfig.awk "$VALUE" "$FILENAME" > "$FILENAME.bak"
  mv -f "$FILENAME.bak" "$FILENAME"
}
