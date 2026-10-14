# 🤖 ROSorin Workspace – Gazebo, SLAM and Navigation Guide

![ROS2](https://img.shields.io/badge/ROS_2-Humble-22314E?logo=ros&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Supported-2496ED?logo=docker&logoColor=white)
![VS Code](https://img.shields.io/badge/VS_Code-Dev_Containers-007ACC?logo=visual-studio-code&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04-E95420?logo=ubuntu&logoColor=white)

This document describes the correct workflow for running the project in order: clone the repository, build the Docker image, run the container, open the project in VS Code using the Dev Container, build the ROS package, start Gazebo, run SLAM to map the environment, save the map, and then run Navigation and control the robot in RViz.

---

## 📑 Table of Contents
1. [Clone the project to your machine](#1-clone-the-project-to-your-machine)
2. [Download and replace the simulation assets](#2-download-and-replace-the-simulation-assets)
3. [Build the Docker image](#3-build-the-docker-image)
4. [Run the Docker container](#4-run-the-docker-container)
5. [Install the Dev Containers extension in VS Code](#5-install-the-dev-containers-extension-in-vs-code)
6. [Open the project in VS Code using the Dev Container](#6-open-the-project-in-vs-code-using-the-dev-container)
7. [Build the ROS packages inside the container](#7-build-the-ros-packages-inside-the-container)
8. [Run Gazebo](#8-run-gazebo)
9. [Run SLAM to collect the map](#9-run-slam-to-collect-the-map)
10. [Save the map](#10-save-the-map)
11. [Run Navigation](#11-run-navigation)
12. [How to control the robot in RViz](#12-how-to-control-the-robot-in-rviz)
13. [Main commands summary](#13-main-commands-summary)
14. [Recommended execution flow for the project](#14-recommended-execution-flow-for-the-project)
15. [Important notes](#15-important-notes)

---

## 📥 1. Clone the project to your machine

```bash
git clone https://github.com/ngkhanh-dev/rosorin-pro-slam-nav
cd ~/rosorin_ws
```

> **Note:** If the repository is already available on your machine, go to the root folder before building Docker:
> ```bash
> cd ~/rosorin_ws
> ```

## 📦 2. Download and replace the simulation assets

Before building the Docker image, go to the shared Google Drive folder below and download the required simulation package:

🔗 **[Download Simulation Assets here](https://drive.google.com/drive/folders/1sq3698U-EX7a4gbjmGnwYbptlJ3B8aMM)**

**Steps to replace assets:**
1. Download the archive and extract it.
2. Find the extracted folder named `simulations`.
3. Replace the existing folders `robot_gazebo` and `rosorin_description` in your project with the matching folders inside the extracted `simulations` directory.
4. Copy the hidden file `.typerc` into the root of your project folder:

```bash
cp /path/to/downloaded/simulations/.typerc ~/rosorin_ws/
```

> ⚠️ **Important:** This step is required so the project uses the correct Gazebo world resources and robot description files.

---

## 🐳 3. Build the Docker image

From the project root, run:

```bash
cd ~/rosorin_ws
docker build -t rosorin .
```

> 💡 **Note:** This step is required before opening the project in the container. If Docker is not installed or not running, install Docker Desktop or Docker Engine first.

---

## 🚀 4. Run the Docker container

After building the image, run the container with:

```bash
docker run -it \
  --name rosorin \
  --network host \
  --gpus all \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  -v ~/rosorin_ws:/home/ros/rosorin_ws \
  rosorin \
  bash
```
*(If you want to use a different image name, replace `rosorin` with your own image name).*

Once inside the container shell, go to the project folder:

```bash
cd /home/ros/rosorin_ws
```

**Automate Environment Setup:**
After entering the project directory inside the container, enable the environment setup automatically by adding the following lines to your shell configuration:

```bash
echo "source ~/rosorin_ws/install/setup.bash" >> ~/.bashrc
echo "source ~/rosorin_ws/.typerc" >> ~/.bashrc
```

Then reload the shell config:

```bash
source ~/.bashrc
```
*This ensures that ROS environment variables and the project-specific configuration are loaded automatically every time you open a terminal.*

---

## 🔌 5. Install the Dev Containers extension in VS Code

In VS Code:
1. Open **Extensions** (`Ctrl+Shift+X` or `Cmd+Shift+X`).
2. Search for `Dev Containers`.
3. Install the **Dev Containers** extension provided by Microsoft.

---

## 💻 6. Open the project in VS Code using the Dev Container

There are two ways to do this:

### Method 1: Reopen in Container
1. Open the project folder in VS Code.
2. Click the **blue button** in the bottom-left corner.
3. Choose: `Dev Containers: Reopen in Container`
4. Select `Use Existing Dockerfile` or `From Dockerfile` if prompted.
5. Choose the `Dockerfile` in the project root.

### Method 2: Create a `.devcontainer` config if needed
If the project does not yet include a Dev Container configuration, create `.devcontainer/devcontainer.json` with the following content:

```json
{
  "name": "rosorin",
  "build": {
    "dockerfile": "../Dockerfile",
    "context": ".."
  },
  "workspaceFolder": "/home/ros/rosorin_ws",
  "remoteUser": "ros"
}
```

Then in VS Code, choose: `Dev Containers: Reopen in Container`

> ✨ **Success:** Once the project opens correctly inside the container, you can work as if you are inside the ROS Docker environment.

---

## 🛠️ 7. Build the ROS packages inside the container

After entering the container or Dev Container, run:

```bash
cd ~/rosorin_ws
source /opt/ros/humble/setup.bash
rosdep update
colcon build --symlink-install
source install/setup.bash
```

> 🔧 **Troubleshooting:** If dependency issues appear during the build, install them using the warnings shown by the build, for example:
> ```bash
> rosdep install --from-paths src --ignore-src -r -y
> ```

---

## 🏙️ 8. Run Gazebo

Open a **new terminal** in VS Code or inside the container and run:

```bash
cd ~/rosorin_ws
source install/setup.bash
ros2 launch robot_gazebo worlds.launch.py world_name:=robocup_home
```
*This command starts Gazebo and spawns the robot into the `robocup_home` world.*

---

## 🗺️ 9. Run SLAM to collect the map

Open a **second terminal** and run the SLAM launch file:

```bash
cd ~/rosorin_ws
source install/setup.bash
ros2 launch /home/ros/rosorin_ws/install/robot_gazebo/share/robot_gazebo/launch/include/slam.launch.py
```

Once SLAM starts, the RViz SLAM interface will open. Now drive the robot in Gazebo to scan the entire environment:
* Use keyboard control or teleop to move the robot around the environment.
* Drive the robot around the target area you want to map.
* Keep the LiDAR sensor scanning walls and corners thoroughly.

**Optional - Teleop Control:**
If the project includes teleop, you can launch it in a new terminal:
```bash
ros2 run teleop_twist_keyboard teleop_twist_keyboard --ros-args -r /cmd_vel:=/cmd_vel
```
*(If teleop is not available, use the appropriate control method for your robot).*

---

## 💾 10. Save the map

When the robot has scanned enough of the area and the map is complete, open a **new terminal** and run:

```bash
cd ~/rosorin_ws
source install/setup.bash
ros2 run nav2_map_server map_saver_cli -f ~/rosorin_ws/src/robot_gazebo/maps/my_map
```

This saves the map into the folder: `~/rosorin_ws/src/robot_gazebo/maps/`

The generated files will look like:
* `my_map.pgm`
* `my_map.yaml`

You can open the YAML file to check the image path, for example:
```yaml
image: my_map.pgm
```

---

## 📍 11. Run Navigation

After saving the map, **stop the SLAM command** (`Ctrl+C`), then start navigation in a new terminal:

```bash
cd ~/rosorin_ws
source install/setup.bash
ros2 launch /home/ros/rosorin_ws/install/robot_gazebo/share/robot_gazebo/launch/include/navigation.launch.py \
  map:=/home/ros/rosorin_ws/install/robot_gazebo/share/robot_gazebo/maps/map_rosorin.yaml
```

This command launches the Nav2 navigation stack, including:
* RViz
* Localization
* Nav2 stack
* Map loader

*In other words, this runs navigation and prepares the robot to move according to goals placed on the map.*

---

## 🎮 12. How to control the robot in RViz

Once navigation is running, RViz will show the following tools:

### 🎯 12.1. Single-point navigation
1. Select the **`2D Pose Estimate`** tool in RViz.
2. Click the correct initial position of the robot on the map.
3. Set the correct heading of the robot.
4. Then select **`2D Goal Pose`** or **`Nav2 Goal`**.
5. Choose a point on the map as the destination.
6. Set the desired heading at the goal position.
7. The robot will plan a path and drive toward the target in Gazebo.

### 🛣️ 12.2. Multi-point navigation
If you want to control multiple goals in sequence:
1. Look at the control bar at the lower-left of RViz.
2. Select the **`Waypoint` / `Nav Through Poses`** mode.
3. Click **`Nav2 Goal`**.
4. Select multiple points on the map in the desired order.
5. Choose **`Start Waypoint Following`** to move through each goal one by one.

**Difference between modes:**
* 🟢 **If you choose `Start Waypoint Following`:**
  The robot will plan a route through each waypoint in order. Each target is processed sequentially.
* 🔵 **If you choose `Start Nav Through Poses`:**
  The robot will plan a continuous path through all selected goals. The path is drawn continuously from one goal to the next.

---

## 📝 13. Main commands summary

| Action | Command |
|--------|---------|
| **Run Gazebo** | `ros2 launch robot_gazebo worlds.launch.py world_name:=robocup_home` |
| **Run SLAM** | `ros2 launch /home/ros/rosorin_ws/install/robot_gazebo/share/robot_gazebo/launch/include/slam.launch.py` |
| **Save map** | `ros2 run nav2_map_server map_saver_cli -f ~/rosorin_ws/src/robot_gazebo/maps/my_map` |
| **Run navigation** | `ros2 launch /home/ros/rosorin_ws/install/robot_gazebo/share/robot_gazebo/launch/include/navigation.launch.py map:=/home/ros/rosorin_ws/install/robot_gazebo/share/robot_gazebo/maps/map_rosorin.yaml` |

---

## 🔄 14. Recommended execution flow for the project

The correct order is:

1. **Clone** the repository.
2. **Build** the Docker image:
   ```bash
   cd ~/rosorin_ws
   docker build -t rosorin .
   ```
3. **Start** the Docker container:
   ```bash
   docker run -it --name rosorin --network host --gpus all -v /tmp/.X11-unix:/tmp/.X11-unix:rw -v ~/rosorin_ws:/home/ros/rosorin_ws rosorin bash
   ```
4. **Open** the project in VS Code through Dev Containers.
5. **Build** the ROS workspace inside the container:
   ```bash
   cd ~/rosorin_ws
   source /opt/ros/humble/setup.bash
   colcon build --symlink-install
   source install/setup.bash
   ```
6. **Open terminal 1:** run Gazebo.
7. **Open terminal 2:** run SLAM.
8. **Drive** the robot in Gazebo to scan the map.
9. **Open terminal 3:** save the map.
10. **Stop** the SLAM process.
11. **Run** navigation.
12. **In RViz:**
    * Use `2D Pose Estimate` to place the robot at its initial pose.
    * Use `2D Goal Pose` / `Nav2 Goal` to select the target.
    * Let the robot follow the generated plan.
13. **For multi-goal tasks**, use waypoint / nav through poses as described above.

---

## ⚠️ 15. Important notes

* 🖥️ **GUI Support:** If you run Gazebo on the host machine, X11 forwarding or GUI support must be enabled. This is why the `/tmp/.X11-unix` mount is necessary.
* 📦 **Dev Containers:** When using Dev Containers, it is recommended to use the project `Dockerfile` so the ROS environment matches the required setup.
* 🗺️ **Map Files:** Before starting navigation, ensure the map file already exists and the path in the command matches the project structure. If the map does not load, check that the `.yaml` and `.pgm` files are in the correct folder.

---

## ✨ 16. Conclusion

The correct workflow for this project is:

```text
Clone repo 
  ➔ Build Docker image 
  ➔ Run container 
  ➔ Open VS Code via Dev Containers 
  ➔ Build ROS workspace 
  ➔ Run Gazebo 
  ➔ Run SLAM 
  ➔ Drive the robot to scan the map 
  ➔ Save the map 
  ➔ Stop SLAM 
  ➔ Run navigation 
  ➔ Use RViz to set pose and goal 
  ➔ Robot moves along the plan
```