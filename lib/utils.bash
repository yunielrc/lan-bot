#######################################
# Imprime un mensaje de error
# Arguments:
#   1: ruta completa del archivo oui.txt
#   2: [código de error]
#######################################
err() {
  local -r msg="$1"
  local -r exitCode="${2:-0}"
  echo "Error: ${msg}" 1>&2
  if [[ "$exitCode" -gt 0 ]]; then
    exit "$exitCode"
  fi
}

#######################################
# Generar una mac
# Arguments:
#   1: ruta completa del archivo oui.txt
# Returns:
#   0: mac generada
#   74: si no se encontró el archivo oui.txt
#######################################
random_mac() {
  local -r ouiFile="$1"
  
  if [ ! -f "$ouiFile" ]; then
    err "No se encontró el archivo oui.txt '$ouiFile'" "$EX_IOERR"
  fi
  
  local -r oui="$(grep -oh  '^[0-9A-Fa-f]\{6\}' "$ouiFile" | shuf -n 1)"
  local -r  random3hex="$(openssl rand -hex 3)"
  
  echo "${oui^^}${random3hex^^}" | sed 's/\(..\)/\1:/g; s/:$//'
  return 0
}

#######################################
# Genera una cadena de caracteres aleatoria entre 6 y 15 caracteres
# Arguments:
#   1: cantidad de caracteres
#######################################
random_alphanumeric() {
  # shellcheck disable=2002
  cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w "$((RANDOM % 10 + 6))" | head -n 1
  return 0
}

#######################################
# Generar un nombre de host aleatorio
# 
# Arguments:
#   1: ruta completa del archivo hostnames.db
#
# Returns:
#   0: host name
#   74: si no se encontró el archivo hostnames.db
#######################################
random_host_name() {
  local -r hostnames="$1"

  if [ ! -f "$hostnames" ]; then
    err "No se encontró el archivo hostnames.db '$hostnames'" "$EX_IOERR"
  fi  

  shuf -n 1 "$hostnames"

  return 0
}

file_name(){
  local -r fileFullPath="${1:-}"
  if [ -z "$fileFullPath" ]; then
    return
  fi
  
  local filename="${fileFullPath%.*}"
  echo "${filename##*/}"
}