## Globals  
# shellcheck disable=2155
readonly MAIN_PATH="$PWD"
readonly TEST_DIR="${MAIN_PATH}/test"
readonly TEST_STUBS_DIR="${TEST_DIR}/stubs"
readonly TEST_STUBS_TASKS_DIR="${TEST_STUBS_DIR}/tasks"
##

## ENV
export PATH="${MAIN_PATH}:${PATH}"
export BASE_PATH="$MAIN_PATH"
##

## Includes
# shellcheck disable=1090
source "${MAIN_PATH}/lib/exit-codes.bash"
# shellcheck disable=1090
source "${MAIN_PATH}/lib/utils.bash"
# shellcheck disable=1090
source "${MAIN_PATH}/services/airos-client.bash"
##