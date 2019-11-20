#!/usr/bin/env bats

load ../test_helper

readonly TEST_FILE='lib/utils.bash'

## err
@test "Se imprime un mensaje de error, sin código de salida especificado, codigo 0 '${TEST_FILE}:err'" {
    local -r msg="mensaje de error"
    run err "$msg"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "$msg" ]]
}

@test "Se imprime un mensaje de error, con código de salida 1, codigo 1 '${TEST_FILE}:err'" {
    local -r msg="mensaje de error"
    local -r code=1
    run err "$msg" "$code"
    [ "$status" -eq "$code" ]
    [[ "$output" =~ "$msg" ]]
}

@test "Se imprime un mensaje de error, con código de salida A, codigo 0 '${TEST_FILE}:err'" {
    local -r msg="mensaje de error"
    local -r code='A'
    run err "$msg" "$code"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "$msg" ]]
}
##

## random_mac
@test "No se genera la mac, no se pasa ruta del archivo 'oui.txt', codigo 74 '${TEST_FILE}:random_mac'" {
    run random_mac
    [ "$status" -eq 74 ]
    [[ "$output" =~ 'No se encontró el archivo oui.txt' ]]
}

@test "No se genera la mac, ruta incorrecta de 'oui.txt', codigo 74 '${TEST_FILE}:random_mac'" {
    run random_mac 'oui.txt'
    [ "$status" -eq 74 ]
    [[ "$output" =~ 'No se encontró el archivo oui.txt' ]]
}

@test "Se genera la mac, ruta correcta de 'oui.txt', codigo 0 '${TEST_FILE}:random_mac'" {
    run random_mac "${MAIN_PATH}/etc/oui.txt"
    [ "$status" -eq 0 ]
    [[ "$output" =~ ^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$ ]]
}
##

## random_alphanumeric
@test "Se genera una cadena '[a-zA-Z0-9]{6,15}', codigo 0 '${TEST_FILE}:random_alphanumeric'" {
    run random_alphanumeric
    [ "$status" -eq 0 ]
    [[ "$output" =~ ^[a-zA-Z0-9]{6,15}$ ]]
}
##

## random_host_name
@test "No existe el archivo hostnames.db, codigo ${EX_IOERR} '${TEST_FILE}:random_host_name'" {
    run random_host_name "${MAIN_PATH}/etc/hostnames.db1"
    [ "$status" -eq $EX_IOERR ]
}

@test "Se genera un nombre de host aleatorio, todo minúscula '${TEST_FILE}:random_host_name'" {
    local -r name="TODO MINUSCULA"
    readonly CASE_OPT=0

    run random_host_name <(echo "$name")

    [ "$status" -eq 0 ]
    [[ "$output" == "${name,,}" ]]
}

@test "Se genera un nombre de host aleatorio, todo mayúscula '${TEST_FILE}:random_host_name'" {
    local -r name="todo mayuscula"
    readonly CASE_OPT=1

    run random_host_name <(echo "$name")

    [ "$status" -eq 0 ]
    [[ "$output" == "${name^^}" ]]
}

@test "Se genera un nombre de host aleatorio, solo primer caracter mayúscula '${TEST_FILE}:random_host_name'" {
    local -r name="primer caracter mayuscula"
    readonly CASE_OPT=2

    run random_host_name <(echo "$name")

    [ "$status" -eq 0 ]
    [[ "$output" == "${name^}" ]]
}
##

## file_name
@test "Sin argumento, imprime nombre vacio '${TEST_FILE}:file_name'" {
    run file_name

    [ "$status" -eq 0 ]
    [[ -z "$output" ]]
}

@test "Con argumento, imprime nombre del archivo sin extensión '${TEST_FILE}:file_name'" {
    run file_name '/tmp/file.txt'

    [ "$status" -eq 0 ]
    [[ "$output" == 'file' ]]
}

##