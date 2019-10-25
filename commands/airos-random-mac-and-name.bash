
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
print_help(){
  local oui="${1:-'/tmp/oui.txt'}"
  
  cat <<HELPMSG
  ${SCRIPT_NAME}, version ${SCRIPT_VERSION}

  Cambia la mac de la interfaz WAN y el nombre de red a un dispositivo AirOS
  a partir de valores aleatorios. Si tuvo éxito imprime la nueva mac y el nuevo
  nombre del dispositivo AirOS

  Requisitos:
  - El dispositivo AirOS debe tener agregada la clave pública del sistema donde
    se ejecuta este script. A continuación se muestra cómo agregadarla al dispositivo:
    1- Descarga la clave pública del dispositivo donde se ejecuta este script a tu PC.
    2- Entra a la interfaz web del dispositivo AirOS 'SERVICES/SSH Server/', toca el
      botón 'Edit' y agrega la clave pública descargada.
  - Tener habilitada la opción 'Network/WAN Network Settings/MAC Address Cloning'
    en el dispositivo AirOS.

  Uso: ${SCRIPT_NAME} --user john --ip 192.168.0.1 [--reboot] \\
      [--oui ${oui}]

    -h, --help, --ayuda
      muestra la ayuda
    -u, --user, --usuario
      usuario del dispositivo AirOS
    -i, --ip
      ip del dispositivo AirOS
    -o, --oui
      ruta completa del archivo oui.txt
    -r, --reboot, --reiniciar
      reinicia el dispositivo AirOS para aplicar los cambios

  Exit status:
  0: Configuración cambiada en dispositivo AirOS
  65: Parámetro no válido
  69: Host AirOS inalcanzable
  74: No se encontró el archivo oui.txt
  255: Acceso ssh al dispositivo AirOS denegado
HELPMSG
}

main(){
  local user=''
  local ip=''
  local oui="$SCRIPT_PATH/etc/oui.txt"
  local reboot=1
  
  if [ "$#" -eq 0 ]; then
    eval set -- '-h'
  fi
  
  while (( "$#" )); do
    case "$1" in
      -u|--user|--usuario)
        user=$2
        shift 2
      ;;
      -i|--ip)
        ip=$2
        shift 2
      ;;
      -o|--oui)
        oui=$2
        shift 2
      ;;
      -r|--reboot|--reiniciar)
        reboot=0
        shift 1
      ;;
      -h|--help|--ayuda)
        print_help "$oui"
        exit 0
      ;;
      --) # end argument parsing
        shift
        break
      ;;
      -*) 

      ;;
    esac
  done
  
  airos_set_mac_and_name "$user" "$ip" "$oui" "$reboot"
}

main "$@"