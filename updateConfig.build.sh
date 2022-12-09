#!/usr/bin/env bash

AWK_MINIFIED=$(awk -v 'RS=' '{gsub(/\n/,"");gsub(/ +/," "); print $0}' updateConfig.awk)
SCRIPT_MINIFIED=$(awk '
  {
    gsub(/ +/," ");
    if (length($0) == 0 || match($0, /(\{|then|else)$/)) {
      printf "%s", $0;
    } else if (match($0, /\}$/)) {
      print " " $0;
    } else {
      printf "%s", $0 ";";
    }
  }
' updateConfig.sh)
echo "# updateConfig version $(cat version)" > updateConfig.compiled.sh
echo "${SCRIPT_MINIFIED/'-f updateConfig.awk'/\'"${AWK_MINIFIED}"\'}" >> updateConfig.compiled.sh
