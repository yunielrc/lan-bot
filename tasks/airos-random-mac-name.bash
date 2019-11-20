# Modifica la mac y el nombre del dispositivo AirOS a partir de valores generados.

## Includes
# shellcheck disable=1090
source "${SERVICES_DIR}/airos-client.bash"
##


#######################################
# Muestra la ayuda
#
# Arguments:
#   1: ruta completa por defecto de oui.txt
# Globals:
#   SCRIPT_NAME
#   SCRIPT_VERSION
# Returns:
#   None
#######################################
usage(){


  local -r TASK="$(file_name "${BASH_SOURCE[0]}")"

  cat <<HELPMSG
  Usage: 
  ${ENTRY_POINT} ${TASK} [OPTIONS]

  Cambia la mac de la interfaz WAN y el nombre de red a un dispositivo AirOS
  a partir de valores aleatorios. Si tuvo éxito imprime la nueva mac y el nuevo
  nombre del dispositivo AirOS.

  Requisitos:
  - El dispositivo AirOS debe tener agregada la clave pública del sistema donde
    se ejecuta este script. A continuación se muestra cómo agregadarla al dispositivo:
    1- Descarga la clave pública del dispositivo donde se ejecuta este script a tu PC.
    2- Entra a la interfaz web del dispositivo AirOS 'SERVICES/SSH Server/', toca el
      botón 'Edit' y agrega la clave pública descargada.
  - Tener habilitada la opción 'Network/WAN Network Settings/MAC Address Cloning'
    en el dispositivo AirOS.

  Options:
    -h, --help             Muestra la ayuda
    -u, --user,            Usuario del dispositivo AirOS
    -i, --ip               IP del dispositivo AirOS
    -o, --oui              Ruta completa del archivo oui.txt
    -r, --reboot           reinicia el dispositivo AirOS para aplicar los cambios
  
  Example:
  ${ENTRY_POINT} ${TASK} --user john --ip 192.168.0.1 [--reboot]

  Exit status:
  0: Configuración cambiada en dispositivo AirOS
  65: Parámetro no válido
  69: Host AirOS inalcanzable
  74: No se encontró el archivo oui.txt
  255: Acceso ssh al dispositivo AirOS denegado
HELPMSG
}

airos-random-mac-name.run(){
  local user=''
  local ip=''
  local oui="${ETC_DIR}/oui.txt"
  local reboot=1
  
  if [[ "$#" == 0 ]]; then
    set -- '-h'
  fi
  
  while (( "$#" )); do
    case "$1" in
      -u|--user|--usuario)
        user=$2
        shift
      ;;
      -i|--ip)
        ip=$2
        shift
      ;;
      -o|--oui)
        oui=$2
        shift
      ;;
      -r|--reboot|--reiniciar)
        reboot=0
      ;;
      -h|--help|'')
        usage
        exit 0
      ;;
      *)
        usage
        exit 1       
      ;;
    esac
    shift
  done
  
  airos.set_random_mac_and_name "$user" "$ip" "$oui" "$reboot"
}