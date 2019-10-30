#!/usr/bin/env bats

load test_helper

readonly TEST_FILE='lb-logger'


setup() {
  readonly TMP_DIR="$(mktemp -d -t lb-logger-XXXXXXXXXX)"
  readonly TMP_LOG="${TMP_DIR}/lan-bot.log"
}

teardown() {
  [[ "$TMP_DIR" == '/tmp/'* ]] && rm -rf  "$TMP_DIR"
}

echo_lb_logger() {
  echo 'log message' | lb-logger "$@"
}

noecho_lb_logger() {
  echo '' | lb-logger "$@"
}

@test "Muestra ayuda '${TEST_FILE}'" {
  local -r out="Usage: lan-bot task-xxx --param pvalue | lb-logger ~/logfile"
  # sin parámetros
  run echo_lb_logger

  [ "$status" -eq 0 ]
  [[ "$output" == "$out" ]]

  # -h
  run echo_lb_logger -h

  [ "$status" -eq 0 ]
  [[ "$output" == "$out" ]]

  # -h
  run echo_lb_logger --help

  [ "$status" -eq 0 ]
  [[ "$output" == "$out" ]]    
}

@test "Path de log incorrecto '${TEST_FILE}'" {
  local -r code="$EX_ARGERR"
  local -r out="Path de log incorrecto"

  local logfile='/a b/c.l og'

  run echo_lb_logger "$logfile"
     
  [[ "$status" == "$code" ]]
  [[ "$output" == *"$out"* ]]

  local logfile='log a'

  run echo_lb_logger "$logfile"
     
  [[ "$status" == "$code" ]]
  [[ "$output" == *"$out"* ]]
}

@test "Sin texto para hacer log '${TEST_FILE}'" {
  local -r code="$EX_ARGERR"
  local -r out="Sin texto para hacer log"
  local logfile='/tmp/lb-log'

  run noecho_lb_logger "$logfile"
     
  [[ "$status" == "$code" ]]
  [[ "$output" == *"$out"* ]]  
}

@test "Escritura denegada al log '${TEST_FILE}'" {
  declare -i code=1
  local -r out="Permiso denegado"
  local logfile='/lb-log'

  run echo_lb_logger "$logfile"

  [[ "$status" == $code ]]
  [[ "$output" == *"$out"* ]]  
}

@test "Entrada añadida al log '${TEST_FILE}'" {
  declare -i code=0
  local -r out="Permiso denegado"
  local logfile="$TMP_LOG"

  run echo_lb_logger "$logfile"
     
  [[ "$status" == 0 ]]
  [[ -z "$output" ]]

  grep --silent 'log message' "$logfile"
}