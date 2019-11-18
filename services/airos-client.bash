
#######################################
# Cambia la configuración en el dispositivo AirOS
#
# Arguments:
#   1: usuario
#   2: ip del dispositivo
#   3: configuración
#  ejemplo: 'netconf.1.hwaddr.mac=B8:07:16:ad:06:34
#            resolv.host.1.name=WOAALHM944'
#  [4: reiniciar dispositivo = 1]
#   5: puerto ssh
#   6: clave privada ssh
#
# Returns:
# 0: configuración cambiada en dispositivo AirOS
# 65: parámetro no válido
# 69: host AirOS inalcanzable
# 255: acceso ssh a AirOS denegado
#######################################
airos.set_config() {
  local -r defaultkey=~/.ssh/id_rsa
  local -r user="$1" ip="$2" config="$3" reboot="${4:-1}" puerto=${5:-22} \
  privatekey="${6:-"$defaultkey"}"

  local -r airoscfg='/tmp/system.cfg'
  
  if [ -z "$user" ]; then
    err "el nombre de usuario es obligatorio" "$EX_DATAERR"
  fi
  if [[ ! "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    err "ip: '${ip}' no válida" "$EX_DATAERR"
  fi
  if [ -z "$config" ]; then
    err "la configuración es obligatoria" "$EX_DATAERR"
  fi
  if ! ping -c 1 "$ip" &> /dev/null; then
    err "El dispositivo AirOS con ip: '${ip}' es inalcanzable" "$EX_UNAVAILABLE"
  fi
  
  local rebootCMD=''
  if [[ "$reboot" -eq 0 ]]; then
    rebootCMD='reboot'
  fi
  
  local ret=0
  (
    # shellcheck disable=2215,2087
    ssh -p "$puerto" \
    -o 'ConnectTimeout=1' \
    -o 'BatchMode=yes' \
    -o 'UserKnownHostsFile=/dev/null' \
    -o 'StrictHostKeyChecking=no'  \
    -i "$privatekey" \
  -T "${user}@${ip}" &> /dev/null <<SSHEOF
  config='$config'
  for keyvalue in \$config; do
    key="\${keyvalue%%=*}"
    # local value=\${keyvalue##*=}
    sed -i "s/^\${key}=.*/\${keyvalue}/g" "$airoscfg"
  done
  save
  ${rebootCMD}
SSHEOF
  ) || ret=$?
  
  if [[ $ret == 255 ]]; then
    err "Acceso denegado a '${user}@${ip}'" "$ret"
  fi
  
  if [[ $ret -ne 0 ]]; then
    err "A ocurrido un error en '${user}@${ip}', código de error: $ret" "$ret"
  fi
  return 0
}

#######################################
# Cambia la mac de la interfaz WAN y el nombre del dispositivo AirOS
#
# Globals:
# utils_host_random_name
# utils_host_random_name_params
#
# Arguments:
#   1: usuario
#   2: ip del dispositivo
#   3: ruta completa del archivo oui.txt
#   [4: reiniciar dispositivo = 1]
#   5: puerto ssh
#   6: clave privada ssh
#
# Returns:
# 0:     nombre y mac cambiadas en el dispositivo AirOS
# 1-255: error
#######################################
airos.set_random_mac_and_name() {
  local -r defaultkey=~/.ssh/id_rsa
  local -r user="$1" ip="$2" oui="$3" reboot="${4:-1}" puerto=${5:-22} \
  privatekey="${6:-"$defaultkey"}"
  local -r mac="$(random_mac "${oui}")"
  [[ -z "$mac" ]] && exit "$EX_IOERR"
  # shellcheck disable=2145
  local -r name="$("$utils_host_random_name" "$utils_host_random_name_params")"
  local -r config="netconf.1.hwaddr.mac=${mac}
  resolv.host.1.name=${name}"
  
  airos.set_config "$user" "$ip" "$config" "$reboot" "$puerto" "$privatekey"
  #   ret=$?
  #   if [[ "$ret" == 0 ]]; then
  #     cat <<EOF
  #     airmac:${mac}
  #     airname:${name}
  # EOF
  #   else
  #      err "No se pudo modificar la configuración" 1
  #   fi
}