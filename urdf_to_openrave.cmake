cmake_minimum_required(VERSION 2.8.3)
# TODO: This is a hack. We should find a more automatic way of adding this
# directory to OpenRAVE's plugin search path.
set(ENV{OPENRAVE_PLUGINS} /opt/ros/$ENV{ROS_DISTRO}/lib/openrave0.9/)
execute_process(COMMAND rosrun or_urdf load.py ${INPUT_PATH} ${OUTPUT_PATH})
