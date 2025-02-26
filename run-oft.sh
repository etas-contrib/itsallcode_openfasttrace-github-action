#!/bin/bash

fail_on_error=${OFT_FAIL_ON_ERROR:-"false"}
report_file_name=${OFT_REPORT_FILENAME:-"trace-report.txt"}
report_format=${OFT_REPORT_FORMAT:-"plain"}
tags=${OFT_TAGS:-""}
file_patterns=${OFT_FILE_PATTERNS:-"."}

options=(-o "$report_format" -f "$report_file_name")
# [impl->req~filter-specitems-using-tags~1]
if [[ -n "$tags" ]]; then
  options=("${options[@]}" -t "$tags")
fi

echo "::notice::using OpenFastTrace JARs from: ${LIB_DIR}"
echo "::notice::running OpenFastTrace for file patterns: $file_patterns"

# [impl->req~run-oft-trace-command~1]
# shellcheck disable=SC2086
# we need to provide the file patterns unquoted in order for the shell to expand any glob patterns like "*.md"
if (java -cp "${LIB_DIR}/*" org.itsallcode.openfasttrace.core.cli.CliStarter trace "${options[@]}" $file_patterns)
then
  echo "oft-exit-code=0" >> "${GITHUB_OUTPUT}"
  echo "All specification items are covered." >> "${GITHUB_STEP_SUMMARY}"
else
  oft_exit_code=$?
  echo "oft-exit-code=${oft_exit_code}" >> "${GITHUB_OUTPUT}"
  echo "Some specification items are not covered. See created report (${report_file_name}) for details." >> "${GITHUB_STEP_SUMMARY}"
  if [ "${fail_on_error}" = "true" ]; then
    exit ${oft_exit_code}
  fi
fi
