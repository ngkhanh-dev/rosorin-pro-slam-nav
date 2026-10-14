

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo git nano curl wget mesa-utils python3-pip \
    sudo apt install ros-humble-topic-tools \
    python3-colcon-common-extensions python3-rosdep python3-vcstool \
    ros-humble-gazebo-ros-pkgs \
    ros-humble-gazebo-ros2-control \
    ros-humble-ros2-control ros-humble-ros2-controllers \
    ros-humble-xacro \
    ros-humble-joint-state-publisher-gui \
    ros-humble-robot-localization \
    ros-humble-teleop-twist-keyboard \
    ros-humble-slam-toolbox \
    ros-humble-cartographer ros-humble-cartographer-ros \
    ros-humble-navigation2 ros-humble-nav2-bringup \
    ros-humble-nav2-simple-commander \
    ros-humble-tf2-tools ros-humble-rqt-tf-tree \
    ros-humble-turtlebot3 ros-humble-turtlebot3-simulations \
    ros-humble-ros-ign-gazebo ros-humble-ros-ign-bridge ros-humble-ign-ros2-control \

    && rm -rf /var/lib/apt/lists/*

ARG USERNAME=ros
ARG USER_UID=1000
ARG USER_GID=1000
RUN groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m -s /bin/bash ${USERNAME} \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME} \
    && usermod -aG video,render ${USERNAME} || true

USER ${USERNAME}
WORKDIR /home/${USERNAME}/rosorin_ws

RUN rosdep update || true

ENV TURTLEBOT3_MODEL=waffle \
    ROS_DOMAIN_ID=30 \
    QT_X11_NO_MITSHM=1 \
    DISPLAY=:1 \
    __NV_PRIME_RENDER_OFFLOAD=1 \
    __GLX_VENDOR_LIBRARY_NAME=nvidia \
    GAZEBO_MODEL_PATH=/home/${USERNAME}/.gazebo/models:/usr/share/gazebo-11/models
RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc \
    && echo "source /usr/share/gazebo-11/setup.sh" >> ~/.bashrc \
    && echo '[ -f ~/rosorin_ws/install/setup.bash ] && source ~/rosorin_ws/install/setup.bash' >> ~/.bashrc \
    && mkdir -p ~/rosorin_ws/src ~/maps

CMD ["bash"]
