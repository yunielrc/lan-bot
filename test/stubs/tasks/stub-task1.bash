# stub task1 text

stub-task1.run(){
  
  if [ "$#" -eq 0 ]; then
    err "Parametros obligatorios" "$EX_ARGERR"
  fi
  
  echo 'OK'
  return 0
}