#!/usr/bin/env bats

load ../test_helper
load airos-client-test_helper

## set_config
@test "Sin parámetros, codigo 65 '${TEST_FILE}:airos.set_config'" {
    run airos.set_config
    [ "$status" -eq 65 ]
    [[ "$output" =~ 'el nombre de usuario es obligatorio' ]]
}

@test "Solo nombre de usuario, codigo 65 '${TEST_FILE}:airos.set_config'" {
    run airos.set_config 'ubnt'
    [ "$status" -eq 65 ]
    [[ "$output" =~ "ip: '' no válida" ]]
}

@test "Ip no válida, codigo 65 '${TEST_FILE}:airos.set_config'" {
    local -r ip='192.168.1234.1'
    run airos.set_config 'ubnt' "$ip"
    [ "$status" -eq 65 ]
    [[ "$output" =~ "ip: '${ip}' no válida" ]]
}

@test "Sin configuración a modificar, codigo 65 '${TEST_FILE}:airos.set_config'" {
    run airos.set_config 'ubnt' '192.168.0.1'
    [ "$status" -eq 65 ]
    [[ "$output" =~ 'la configuración es obligatoria' ]]
}

@test "Ip de servidor de no existente, codigo 69 '${TEST_FILE}:airos.set_config'" {
    local -r ip='192.168.0.89'
    local -r mac='B4:2E:F8:20:c0:4d'
    local -r name='NAME12345'
    local -r config="netconf.1.hwaddr.mac=${mac}
    resolv.host.1.name=${name}"    
        run airos.set_config 'ubnt' $ip "$config"
    [ "$status" -eq 69 ]
    [[ "$output" =~ "El dispositivo AirOS con ip: '${ip}' es inalcanzable" ]]
}

# inicio ssh stub server
@test "Acceso denegado al servidor por usuario incorrecto, codigo 255 '${TEST_FILE}:airos.set_config'" {
    local -r ip="$AIR_HOST"
    local -r mac='B4:2E:F8:20:c0:4d'
    local -r name='NAME12345'
    local -r config="netconf.1.hwaddr.mac=${mac}
    resolv.host.1.name=${name}"
    local -r user='baduser'

    setup_ssh_docker

    run airos.set_config "$user" "$ip" "$config" 1 "$AIR_PORT"
    [ "$status" -eq 255 ]
    [[ "$output" =~ "Acceso denegado a '${user}@${ip}'" ]]
}

@test "Configuración en servidor modificada, codigo 0 '${TEST_FILE}:airos.set_config'" {
    local -r ip="$AIR_HOST"
    local -r mac='B4:2E:F8:20:c0:4d'
    local -r name='NAME12345'
    local -r config="netconf.1.hwaddr.mac=${mac}
    resolv.host.1.name=${name}"
    local -r user='root'  

    setup_ssh_docker
    local -r  docker_tmpdir="$(tmp_dir_ssh_docker)"

    run airos.set_config "$user" "$ip" "$config" "1" "$AIR_PORT"
    [ "$status" -eq 0 ]
    [[ -z "$output" ]]
    
    run grep --silent "netconf.1.hwaddr.mac=${mac}" "${docker_tmpdir}/system.cfg"
    [ "$status" -eq 0 ]
    
    run grep --silent "resolv.host.1.name=${name}" "${docker_tmpdir}/system.cfg"
    [ "$status" -eq 0 ]
}

@test "No se pudo cambiar el nombre y la mac por oui.txt incorrecto '${TEST_FILE}:airos.set_random_mac_and_name'" {
    local -r user='root'
    local -r ip="$AIR_HOST"
    local -r mac='B4:2E:F8:20:c0:4d'
    local -r name='NAME12345'
    local -r bad_oui="oui.txt"

    setup_ssh_docker

    run airos.set_random_mac_and_name "$user" "$ip" "$bad_oui" 1 "$AIR_PORT"
    # echo "status: ${status}, output: ${output}" >> "/tmp/airos-client.bats.log"
    [ "$status" -eq "$EX_IOERR" ]
    [[ "$output" =~ 'No se encontró el archivo oui.txt' ]]
}

@test "Cambiado el nombre la y mac al dispositivo AirOS '${TEST_FILE}:airos.set_random_mac_and_name'" {
    local -r ip="$AIR_HOST"
    local -r oui="${MAIN_PATH}/test/fixtures/oui.txt"
    local -r user='root'

    setup_ssh_docker

    run airos.set_random_mac_and_name "$user" "$ip" "$oui" 1 "$AIR_PORT"
    # echo "status: ${status}, line0: ${lines[0]}" >> "/tmp/airos-client.bats.log"
    # echo "status: ${status}, line1: ${lines[1]}" >> "/tmp/airos-client.bats.log"
    down_ssh_docker

    [ "$status" -eq 0 ]
    [[ "${lines[0]}" =~ airmac:([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$ ]]
    [[ "${lines[1]}" =~ airname:[A-Z0-9]{10}$ ]]
}

# fin ssh stub server
##