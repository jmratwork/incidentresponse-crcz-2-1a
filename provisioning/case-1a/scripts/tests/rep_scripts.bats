#!/usr/bin/env bats

setup() {
  export BATS_TMPDIR="$BATS_TEST_TMPDIR"
  mkdir -p "$BATS_TMPDIR/bin"
  PATH="$BATS_TMPDIR/bin:$PATH"
  export PATH

  cat <<'EOS' > "$BATS_TMPDIR/bin/curl"
#!/usr/bin/env bash
set -euo pipefail
log_file="${MOCK_CURL_LOG:-}"
if [[ -n "$log_file" ]]; then
  printf '%s\n' "$*" >> "$log_file"
fi
if [[ -n "${MOCK_CURL_FAIL:-}" && "$*" == *"${MOCK_CURL_FAIL}"* ]]; then
  echo "mock curl: forced failure" >&2
  exit 22
fi
outfile=""
response="${MOCK_CURL_RESPONSE:-{\"status\":\"ok\"}}"
args=("$@")
idx=0
while [[ $idx -lt ${#args[@]} ]]; do
  arg="${args[$idx]}"
  case "$arg" in
    -o)
      ((idx++))
      outfile="${args[$idx]}"
      ;;
  esac
  ((idx++))
end
if [[ -n "$outfile" ]]; then
  printf '%s' "$response" > "$outfile"
else
  printf '%s' "$response"
fi
EOS
  chmod +x "$BATS_TMPDIR/bin/curl"

  export REP_SCHEDULER_API_BASE="https://rep.example/scheduler/api"
  export REP_REPORTING_API_BASE="https://rep.example/reporting/api"
  export REP_API_TOKEN="test-token"
  export MOCK_CURL_LOG="$BATS_TMPDIR/curl.log"
  : > "$MOCK_CURL_LOG"
}

teardown() {
  rm -f "$MOCK_CURL_LOG"
}

@test "schedule_rep_lab posts payload to REP Scheduler" {
  run "$BATS_TEST_DIRNAME/../schedule_rep_lab.sh" "$BATS_TEST_DIRNAME/../examples/lab-schedule.json"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Lab scheduling request submitted"* ]]

  run grep -c 'labs/schedule' "$MOCK_CURL_LOG"
  [ "$status" -eq 0 ]
  [ "$output" -eq 1 ]

  run grep -c 'Authorization: Bearer test-token' "$MOCK_CURL_LOG"
  [ "$status" -eq 0 ]
  [ "$output" -eq 1 ]
}

@test "schedule_rep_lab fails when payload is missing" {
  run "$BATS_TEST_DIRNAME/../schedule_rep_lab.sh" "$BATS_TEST_DIRNAME/../examples/missing.json"
  [ "$status" -ne 0 ]
  [[ "$output" == *"Lab payload"* ]]
}

@test "schedule_rep_lab propagates curl failures" {
  export MOCK_CURL_FAIL='labs/schedule'
  run "$BATS_TEST_DIRNAME/../schedule_rep_lab.sh" "$BATS_TEST_DIRNAME/../examples/lab-schedule.json"
  [ "$status" -ne 0 ]
}

@test "export_quiz_report stores report locally" {
  export MOCK_CURL_RESPONSE='{"report":"ok"}'
  local output_file="$BATS_TMPDIR/report.json"
  run "$BATS_TEST_DIRNAME/../export_quiz_report.sh" rep-course "$output_file"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Quiz report saved"* ]]
  [ -f "$output_file" ]
  run cat "$output_file"
  [ "$status" -eq 0 ]
  [[ "$output" == '{"report":"ok"}' ]]
  run grep -c 'quiz/reports/rep-course' "$MOCK_CURL_LOG"
  [ "$status" -eq 0 ]
  [ "$output" -eq 1 ]
}

@test "export_quiz_report requires course identifier" {
  run "$BATS_TEST_DIRNAME/../export_quiz_report.sh" '' "$BATS_TMPDIR/out.json"
  [ "$status" -ne 0 ]
  [[ "$output" == *"Course identifier"* ]]
}

@test "export_quiz_report propagates curl failure" {
  export MOCK_CURL_FAIL='quiz/reports/'
  run "$BATS_TEST_DIRNAME/../export_quiz_report.sh" rep-course "$BATS_TMPDIR/out.json"
  [ "$status" -ne 0 ]
}
