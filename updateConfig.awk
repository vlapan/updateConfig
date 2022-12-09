function stderr(v) { print "[" fileName "]." v > "/dev/stderr"; }
function singleOrMultiLine(v, brackets) { if (split(v, va, /[\n\t]+/) == 1) { return (brackets ? "(" : "") v (brackets ? ")" : ""); } else { gsub(/\n/, "\n" indent, v); return "(\n" indent v "\n)"; } }
function logChange(a, v1, v2) { stderr(a ": " singleOrMultiLine(v1, !!v2) (!!v2 ? " => " singleOrMultiLine(v2, !!v2) : "")); }
function processChars(v) { gsub(/\\n/, "\n", v); gsub(/\\t/, "\t", v); return v; }
function getArgvClean(i) { v = ARGV[i]; ARGV[i] = ""; return v; }
function pk(v) { if (uncomment == 0 && match(v, /^[#]{1})[ ]{0,1}/)) { return ""; } sub(/^([#]{1}|[\^]{1})[ ]{0,1}/, "", v); sub(/[= \t].*/, "", v); return v; }
function bufferSet(k, v) { bufferKey = k ? k : ""; bufferValue = v ? v : ""; }
function bufferFlush(k, v) {
  if (bufferKey) {
    foundArray[bufferKey] = 0;
    if (bufferValue != inputArray[bufferKey]) { logChange("update", bufferValue, inputArray[bufferKey]); }
    print inputArray[bufferKey];
  }
  bufferSet(k, v);
}
BEGIN {
  indent = sprintf("%" indent "s", "");
  fileName = ARGV[2];
  ac = split(processChars(getArgvClean(1)), a, /\n+/);
  for (i = 0; ++i <= ac;) {
    sub(/^[ \t]+/, "", a[i]);
    ak = pk(a[i]);
    if (length(ak) > 0 && !match(ak, /^#/)) {
      inputArray[ak] = length(inputArray[ak]) ? inputArray[ak] "\n" a[i] : a[i];
      if (match(a[i], /^\^/)) {
        removeArray[ak] = 1;
      } else {
        foundArray[ak] = 1;
      }
    }
  }
  bufferSet();
}
{
  k = pk($0);
  if (length(k) > 0 && k in inputArray) {
    if (foundArray[k] == 0 || removeArray[k] == 1) {
      bufferFlush();
      logChange("remove", $0);
      next;
    }
    if (bufferKey == k) {
      bufferValue = length(bufferValue) ? bufferValue "\n" $0 : $0;
    } else {
      bufferFlush(k, $0);
    }
  } else {
    bufferFlush();
    print;
  }
}
END {
  bufferFlush();
  for (i in foundArray) {
    if (foundArray[i]) {
      logChange("append", inputArray[i]);
      print inputArray[i];
    }
  }
}