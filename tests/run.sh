#!/bin/bash
set -euo pipefail

ROOT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
TEST_DIR=$(mktemp -d)
trap 'rm -rf -- "$TEST_DIR"' EXIT

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

assert_file_contains() {
  local file="$1"
  local text="$2"
  grep -F -- "$text" "$file" >/dev/null || fail "expected '$text' in $file"
}

assert_file_not_contains() {
  local file="$1"
  local text="$2"
  if grep -F -- "$text" "$file" >/dev/null; then
    fail "did not expect '$text' in $file"
  fi
}

HOME="$TEST_DIR/home"
XDG_STATE_HOME="$TEST_DIR/state"
JUSTBUNTU_INSTALL_LOG_FILE="$TEST_DIR/state/justbuntu/install.log"
mkdir -p -- "$HOME"
export HOME XDG_STATE_HOME JUSTBUNTU_INSTALL_LOG_FILE

source "$ROOT_DIR/lib/logging.sh"
source "$ROOT_DIR/lib/reporting.sh"

start_install_log
log_info 'token=do-not-write-this password=also-private'
TEST_SCRIPT="$TEST_DIR/ok.sh"
printf '#!/bin/bash\nlog_info "fixture completed"\n' >"$TEST_SCRIPT"
run_script "$TEST_SCRIPT"
sleep 0.1
finish_install_log completed

[[ "$(stat -c '%a' "$JUSTBUNTU_INSTALL_LOG_FILE")" == '600' ]] || \
  fail 'install log is not private'
assert_file_contains "$JUSTBUNTU_INSTALL_LOG_FILE" '[REDACTED]'
assert_file_not_contains "$JUSTBUNTU_INSTALL_LOG_FILE" 'do-not-write-this'
assert_file_not_contains "$JUSTBUNTU_INSTALL_LOG_FILE" 'also-private'
assert_file_contains "$JUSTBUNTU_INSTALL_LOG_FILE" 'event=script_start'
assert_file_contains "$JUSTBUNTU_INSTALL_LOG_FILE" 'event=script_complete'

JUSTBUNTU_PHASE='test'
CURRENT_SCRIPT_PATH="$ROOT_DIR/tests/run.sh"
JUSTBUNTU_ERROR_FUNCTION='test_failure'
JUSTBUNTU_ERROR_LINE='42'
JUSTBUNTU_ERROR_CODE='1'
JUSTBUNTU_ERROR_COMMAND='curl Authorization: Bearer do-not-write-this'
create_failure_report

[[ "$(stat -c '%a' "$JUSTBUNTU_LAST_REPORT_FILE")" == '600' ]] || \
  fail 'failure report is not private'
assert_file_contains "$JUSTBUNTU_LAST_REPORT_FILE" 'JustBuntu installation failure'
assert_file_contains "$JUSTBUNTU_LAST_REPORT_FILE" '[REDACTED]'
assert_file_not_contains "$JUSTBUNTU_LAST_REPORT_FILE" 'do-not-write-this'

if send_failure_report "$JUSTBUNTU_LAST_REPORT_FILE" ''; then
  fail 'empty token unexpectedly submitted a report'
elif [[ "$?" != '3' ]]; then
  fail 'empty token did not use the local-report fallback'
fi

MOCK_BIN="$TEST_DIR/bin"
mkdir -p -- "$MOCK_BIN"
MOCK_CAPTURE="$TEST_DIR/submitted-payload"
export MOCK_CAPTURE
cat >"$MOCK_BIN/curl" <<'MOCK_CURL'
#!/bin/bash
set -euo pipefail
config=''
response=''
while (($#)); do
  case "$1" in
    --config) config="$2"; shift 2 ;;
    --output) response="$2"; shift 2 ;;
    --write-out) shift 2 ;;
    *) shift ;;
  esac
done
payload=$(sed -n 's/^data-binary = "@\(.*\)"$/\1/p' "$config")
cp -- "$payload" "$MOCK_CAPTURE"
printf '{"html_url":"https://github.com/itsnin/justbuntu/issues/999"}\n' >"$response"
printf '201'
MOCK_CURL
chmod 700 -- "$MOCK_BIN/curl"
PATH="$MOCK_BIN:$PATH"
export PATH
assert_file_contains <(send_failure_report "$JUSTBUNTU_LAST_REPORT_FILE" 'ghp_fixture_token') 'https://github.com/itsnin/justbuntu/issues/999'
assert_file_contains "$MOCK_CAPTURE" 'JustBuntu installation failure'
assert_file_not_contains "$MOCK_CAPTURE" 'ghp_fixture_token'
jq empty "$MOCK_CAPTURE" || fail 'submitted payload is not valid JSON'

ERROR_STATE="$TEST_DIR/error-state"
mkdir -p -- "$ERROR_STATE/home"
if HOME="$ERROR_STATE/home" XDG_STATE_HOME="$ERROR_STATE/state" \
   JUSTBUNTU_INSTALL_LOG_FILE="$ERROR_STATE/state/justbuntu/install.log" \
   bash -c 'set -eEuo pipefail; source "$1/lib/logging.sh"; source "$1/lib/errors.sh"; false' \
   bash "$ROOT_DIR"; then
  fail 'noninteractive failure test unexpectedly succeeded'
fi
find "$ERROR_STATE/state/justbuntu/reports" -type f -name 'failure.*.txt' -print -quit | grep . >/dev/null || \
  fail 'noninteractive failure did not create a report'

printf 'All logging and failure-report tests passed.\n'
