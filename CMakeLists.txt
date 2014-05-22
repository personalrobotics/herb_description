cmake_minimum_required(VERSION 2.8.3)
project(herb_description)

find_package(catkin REQUIRED COMPONENTS xacro)
catkin_package()

set(COMMAND_PARAMS_POSTPROCESS ${PROJECT_SOURCE_DIR}/scripts/postprocess_params.py)
set(COMMAND_XACRO_POSTPROCESS ${PROJECT_SOURCE_DIR}/scripts/postprocess_xacro.py)

macro(postprocess_urdf input_path params_path output_path)
    add_custom_command(OUTPUT ${output_path}
        DEPENDS ${COMMAND_PARAMS_POSTPROCESS} ${input_path} ${params_path}
        COMMAND ${COMMAND_PARAMS_POSTPROCESS} ${input_path} ${params_path} ${output_path}
    )
endmacro()

macro(wrap_xacro input_path output_path)
    get_filename_component(xacro_name "${output_path}" NAME_WE)
    add_custom_command(OUTPUT ${output_path}
        DEPENDS ${COMMAND_XACRO_POSTPROCESS} ${input_path}
        COMMAND ${COMMAND_XACRO_POSTPROCESS}
                --name=${xacro_name} --package=herb_description --collision_meshes=True
                ${input_path} ${output_path}
    )
endmacro()

macro(urdf_to_openrave input_path output_path)
    add_custom_command(OUTPUT ${output_path}
        DEPENDS ${input_path}
        COMMAND rosrun or_urdf load.py ${input_path} ${output_path}
    )
endmacro()

# Create a standalone WAM URDF model.
# TODO: There seems to be a race condition here in parallel builds.
xacro_add_xacro_file(${PROJECT_SOURCE_DIR}/config/wam_params.urdf.xacro wam_params.urdf)
postprocess_urdf(${PROJECT_SOURCE_DIR}/robots/WAM_URDF.URDF wam_params.urdf wam_raw.urdf)
wrap_xacro(wam_raw.urdf wam.urdf.xacro)

add_custom_target(wam_urdf ALL
  DEPENDS wam.urdf.xacro
  COMMENT "Generating WAM URDF"
  VERBATIM
)

# Create a standalone BarrettHand (BH280) URDF model.
xacro_add_xacro_file(${PROJECT_SOURCE_DIR}/config/bh280_params.urdf.xacro bh280_params.urdf)
postprocess_urdf(${PROJECT_SOURCE_DIR}/robots/BHD280_URDF.URDF bh280_params.urdf bh280_raw.urdf)
wrap_xacro(bh280_raw.urdf bh280.urdf.xacro)

add_custom_target(bh280_urdf ALL
  DEPENDS bh280.urdf.xacro
  COMMENT "Generating BH280 URDF"
  VERBATIM
)

# Create the HERB URDF model.
# TODO: We manually depend on wam.urdf.xacro and bh280.urdf.xacro because
# xacro_add_xacro_file doesn't work properly when the included files do not
# exist.
xacro_add_xacro_file(${PROJECT_SOURCE_DIR}/config/herb_params.urdf.xacro herb_params.urdf)
postprocess_urdf(${PROJECT_SOURCE_DIR}/robots/HERB_BASE_URDF.URDF herb_params.urdf herb_base_raw.urdf)
wrap_xacro(herb_base_raw.urdf herb_base.urdf.xacro)
add_custom_command(OUTPUT herb.urdf.xacro
    DEPENDS ${PROJECT_SOURCE_DIR}/robots/herb.urdf.xacro
            herb_base.urdf.xacro wam.urdf.xacro bh280.urdf.xacro
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${PROJECT_SOURCE_DIR}/robots/herb.urdf.xacro herb.urdf.xacro
)
xacro_add_xacro_file(herb.urdf.xacro herb.urdf)

add_custom_target(herb_urdf ALL
  DEPENDS herb.urdf
  COMMENT "Generating HERB URDF"
  VERBATIM
)

# Generate the OpenRAVE model.
urdf_to_openrave(herb.urdf herb.kinbody.xml)
add_custom_target(herb_kinbody ALL
  DEPENDS herb.kinbody.xml
  COMMENT "Generating HERB KinBody"
  VERBATIM
)

install(
    FILES ${CMAKE_CURRENT_BINARY_DIR}/wam.urdf.xacro
          ${CMAKE_CURRENT_BINARY_DIR}/bh280.urdf.xacro
          ${CMAKE_CURRENT_BINARY_DIR}/herb.urdf
    DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}/robots
)
install(
    FILES ordata/robots/herb.robot.xml
          ${CMAKE_CURRENT_BINARY_DIR}/herb.kinbody.xml
    DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}/ordata/robots
)
install(DIRECTORY meshes
    DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}
    PATTERN ".svn" EXCLUDE
)
