#!/usr/bin/env bash
# Dùng: ./run.sh build   -> build image
#       ./run.sh start   -> chạy container (lần đầu) hoặc vào lại
#       ./run.sh shell   -> mở thêm terminal trong container đang chạy
#       ./run.sh rm      -> xóa container (workspace trên máy vẫn còn)
set -e
IMAGE=rosorin:humble
NAME=rosorin
WS="$HOME/rosorin_ws"

case "$1" in
  build)
    docker build -t $IMAGE \
      --build-arg USER_UID=$(id -u) --build-arg USER_GID=$(id -g) .
    ;;
  start)
    mkdir -p "$WS/src" "$WS/maps"
    xhost +local:docker >/dev/null
    if [ "$(docker ps -aq -f name=^${NAME}$)" ]; then
      docker start -ai $NAME
    else
      GPU_ARGS=""
      if command -v nvidia-smi >/dev/null && docker info 2>/dev/null | grep -qi nvidia; then
        GPU_ARGS="--gpus all -e NVIDIA_DRIVER_CAPABILITIES=all"
      fi
      docker run -it --name $NAME \
        --net=host --ipc=host \
        -e DISPLAY=$DISPLAY \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -v "$WS":/home/ros/rosorin_ws \
        -v "$WS/maps":/home/ros/maps \
        --device /dev/dri \
        $GPU_ARGS \
        $IMAGE
    fi
    ;;
  shell) docker exec -it $NAME bash ;;
  rm)    docker rm -f $NAME ;;
  *) echo "Dùng: $0 {build|start|shell|rm}"; exit 1 ;;
esac
