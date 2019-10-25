tmpDir=''

readonly AIR_HOST='127.0.0.1'
readonly AIR_PORT=2222
readonly CONTAINER_NAME='airos_ssh_stub_server'

setup_ssh_docker() {
    # crear Stub server para test case 50 y 64
    if [[ "$(systemctl show --property ActiveState docker)" != 'ActiveState=active' ]]; then
        echo 'docker no se está ejecutando'
        exit 1
    fi

    if ! docker ps | grep --silent "$CONTAINER_NAME" ; then
      local -r tmpDir="$(mktemp -d -t lan-bot-XXXXXXXXXX)"
      install -o "$USER" -m a+r "${MAIN_PATH}/test/files/id_rsa.pub" "${tmpDir}/" && \
      install -o "$USER" -m a+rw "${MAIN_PATH}/test/fixtures/system.cfg" "${tmpDir}/" && \
      install -o "$USER" -m a+xrw "${MAIN_PATH}/test/files/null" "${tmpDir}/" && \

      docker run -d -p ${AIR_PORT}:22 \
      --name "$CONTAINER_NAME" \
      --label "tmpdir=${tmpDir}" \
      -v "$tmpDir/id_rsa.pub":/root/.ssh/authorized_keys \
      -v "$tmpDir/":/tmp/ \
      -v "$tmpDir/null":/usr/bin/save \
      -e SSH_ENABLE_ROOT=true panubo/sshd:latest
      sleep 2
    fi
}

tmp_dir_ssh_docker(){
    docker ps --filter "name=$CONTAINER_NAME" --format '{{.Label "tmpdir"}}'
}

down_ssh_docker() {
    local -r containerID="$(docker ps --filter "name=$CONTAINER_NAME" --format '{{.ID}}' )"

    if [[ -n "$containerID" ]]; then
        local -r tmpDir="$(tmp_dir_ssh_docker)"
        
        if [[  -d "$tmpDir" && "$tmpDir" =~ ^/tmp/ ]]; then
            rm -f -r "$tmpDir"
        fi

        docker container rm -f "$containerID"
    fi
}