cmake_minimum_required(VERSION 2.8.3)
project(herb_description)

find_package(catkin REQUIRED COMPONENTS xacro)
catkin_package()

set(COMMAND_PARAMS_POSTPROCESS ${PROJECT_SOURCE_DIR}/scripts/postprocess_params.py)
set(COMMAND_XACRO_POSTPROCESS ${PROJECT_SOURCE_DIR}/scripts/postprocess_xacro.py)
set(COMMAND_URDF_TO_OPENRAVE rosrun or_urdf urdf_to_openrave)    
set(BASE_OUTPUT_DIR "${CATKIN_DEVEL_PREFIX}/${CATKIN_PACKAGE_SHARE_DESTINATION}")
set(OPENRAVE_OUTPUT_DIR "${BASE_OUTPUT_DIR}")
set(URDF_OUTPUT_DIR "${BASE_OUTPUT_DIR}")

macro(xacro_expand input_path output_path)
    add_custom_command(OUTPUT "${output_path}"
        DEPENDS "${input_path}"
        COMMAND rosrun xacro xacro.py -o "${output_path}" "${input_path}"
    )
endmacro()

macro(postprocess_urdf input_path params_path output_path)
    add_custom_command(OUTPUT "${output_path}"
        DEPENDS ${COMMAND_PARAMS_POSTPROCESS} "${input_path}" "${params_path}"
        COMMAND ${COMMAND_PARAMS_POSTPROCESS} "${input_path}" "${params_path}"
                                              "${output_path}"
    )
endmacro()

macro(wrap_xacro input_path output_path)
    get_filename_component(xacro_name "${output_path}" NAME_WE)
    add_custom_command(OUTPUT "${output_path}"
        DEPENDS ${COMMAND_XACRO_POSTPROCESS} "${input_path}"
        COMMAND ${COMMAND_XACRO_POSTPROCESS}
                --name="${xacro_name}" --package="${PROJECT_NAME}"
                --collision_meshes=True "${input_path}" "${output_path}"
    )
endmacro()

macro(urdf_to_openrave input_path output_path)
    add_custom_command(OUTPUT "${output_path}"
        DEPENDS "${input_path}"
        COMMAND ${COMMAND_URDF_TO_OPENRAVE} "${input_path}" > "${output_path}"
    )
endmacro()

# Create a standalone WAM URDF model.
# TODO: There seems to be a race condition here in parallel builds.
xacro_expand("${PROJECT_SOURCE_DIR}/config/wam_params.urdf.xacro"
             "wam_params.urdf")
postprocess_urdf("${PROJECT_SOURCE_DIR}/robots/WAM_URDF.URDF"
                 "wam_params.urdf" "wam_raw.urdf")
wrap_xacro("wam_raw.urdf" "${URDF_OUTPUT_DIR}/wam.urdf.xacro")

add_custom_target(wam_urdf ALL
  DEPENDS "${URDF_OUTPUT_DIR}/wam.urdf.xacro"
  COMMENT "Generating WAM URDF"
  VERBATIM
)

# Create a standalone BarrettHand (BH280) URDF model.
xacro_expand("${PROJECT_SOURCE_DIR}/config/bh280_params.urdf.xacro"
             "bh280_params.urdf")
postprocess_urdf("${PROJECT_SOURCE_DIR}/robots/BHD280_URDF.URDF"
                 "bh280_params.urdf" "bh280_raw.urdf")
wrap_xacro("bh280_raw.urdf" "${URDF_OUTPUT_DIR}/bh280.urdf.xacro")

add_custom_target(bh280_urdf ALL
  DEPENDS "${URDF_OUTPUT_DIR}/bh280.urdf.xacro"
  COMMENT "Generating BH280 URDF"
  VERBATIM
)

# Create the HERB URDF model.
# TODO: We manually depend on wam.urdf.xacro and bh280.urdf.xacro because
# xacro_add_xacro_file doesn't work properly when the included files do not
# exist.
xacro_expand("${PROJECT_SOURCE_DIR}/config/herb_params.urdf.xacro"
             "herb_params.urdf")
postprocess_urdf("${PROJECT_SOURCE_DIR}/robots/HERB_BASE_URDF.URDF"
                 "herb_params.urdf"
                 "herb_base_raw.urdf")
wrap_xacro("herb_base_raw.urdf" "${URDF_OUTPUT_DIR}/herb_base.urdf.xacro")
add_custom_command(OUTPUT "${URDF_OUTPUT_DIR}/herb.urdf.xacro"
    DEPENDS "${PROJECT_SOURCE_DIR}/robots/herb.urdf.xacro"
            "${URDF_OUTPUT_DIR}/herb_base.urdf.xacro"
            "${URDF_OUTPUT_DIR}/wam.urdf.xacro"
            "${URDF_OUTPUT_DIR}/bh280.urdf.xacro"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${PROJECT_SOURCE_DIR}/robots/herb.urdf.xacro"
            "${URDF_OUTPUT_DIR}/herb.urdf.xacro"
)
xacro_expand("${URDF_OUTPUT_DIR}/herb.urdf.xacro"
             "${URDF_OUTPUT_DIR}/herb.urdf")

add_custom_target(herb_urdf ALL
    DEPENDS "${URDF_OUTPUT_DIR}/herb.urdf"
    COMMENT "Generating HERB URDF"
    VERBATIM
)

# Generate OpenRAVE models.
# TODO: Also create WAM and BarrettHand models.
urdf_to_openrave("${URDF_OUTPUT_DIR}/herb.urdf"
                 "${OPENRAVE_OUTPUT_DIR}/herb.kinbody.xml")
add_custom_target(herb_kinbody ALL
    DEPENDS "${OPENRAVE_OUTPUT_DIR}/herb.kinbody.xml"
    COMMENT "Generating HERB KinBody"
    VERBATIM
)

install(DIRECTORY "${URDF_OUTPUT_DIR}"
    DESTINATION "${CATKIN_PACKAGE_SHARE_DESTINATION}/robots"
)
#install(DIRECTORY "${OPENRAVE_OUTPUT_DIR}"
#    DESTINATION "${CATKIN_PACKAGE_SHARE_DESTINATION}/ordata"
#)

#install(
#    FILES ordata/robots/herb.robot.xml
#          ${CMAKE_CURRENT_BINARY_DIR}/herb.kinbody.xml
#    DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}/ordata/robots
#)
#install(DIRECTORY meshes
#    DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}
#    PATTERN ".svn" EXCLUDE
#)
