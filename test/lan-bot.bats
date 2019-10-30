#!/usr/bin/env bats

load test_helper

readonly TEST_FILE='lan-boot'

setup() {
  export TASK_DIR="$TEST_STUBS_TASKS_DIR"
}

teardown() {
  :
}

@test "Tarea no valida, codigo 79:EX_ARGERR '${TEST_FILE}:run_task'" {
    local task='tarea-123'

    run lan-bot "$task"

    [ "$status" -eq "$EX_ARGERR" ]
    [[ "$output" == *"Tarea no valida: '${task}'" ]]
}

@test "Tarea sin parametros no ejecutada, codigo 79:EX_ARGERR '${TEST_FILE}:run_task'" {
    local task='stub-task1'

    run lan-bot "$task"

    [ "$status" -eq "$EX_ARGERR" ]
    [[ "$output" == *"Parametros obligatorios" ]]
}

@test "Tarea ejecutada '${TEST_FILE}:run_task'" {
    local task='stub-task1'

    run lan-bot "$task" --param 123

    [ "$status" -eq 0 ]
    [[ "$output" =~ "$task".*OK ]]
}