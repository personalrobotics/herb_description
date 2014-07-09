cmake_minimum_required(VERSION 2.8.3)
project(herb_description)

if (DEFINED CATKIN_TOPLEVEL OR (NOT ("$ENV{ROS_DISTRO}" STREQUAL "fuerte")))
    find_package(catkin REQUIRED COMPONENTS or_urdf)
    catkin_package()

    set(BASE_OUTPUT_DIR "${CATKIN_DEVEL_PREFIX}/${CATKIN_PACKAGE_SHARE_DESTINATION}")
else ()
    set(BASE_OUTPUT_DIR "${PROJECT_SOURCE_DIR}")
endif ()

set(COMMAND_PARAMS_POSTPROCESS "${PROJECT_SOURCE_DIR}/scripts/postprocess_params.py")
set(COMMAND_XACRO_POSTPROCESS "${PROJECT_SOURCE_DIR}/scripts/postprocess_xacro.py")

set(OPENRAVE_OUTPUT_DIR "${BASE_OUTPUT_DIR}/ordata")
set(URDF_OUTPUT_DIR "${BASE_OUTPUT_DIR}/robots")

file(MAKE_DIRECTORY "${URDF_OUTPUT_DIR}")
file(MAKE_DIRECTORY "${OPENRAVE_OUTPUT_DIR}")
file(MAKE_DIRECTORY "${OPENRAVE_OUTPUT_DIR}/robots")

file(COPY "${PROJECT_SOURCE_DIR}/robots/wam_standalone.urdf.xacro"
    DESTINATION "${URDF_OUTPUT_DIR}"
)
file(COPY "${PROJECT_SOURCE_DIR}/robots/bh280_standalone.urdf.xacro"
    DESTINATION "${URDF_OUTPUT_DIR}"
)
file(COPY "${PROJECT_SOURCE_DIR}/robots/wam_bh280_standalone.urdf.xacro"
    DESTINATION "${URDF_OUTPUT_DIR}"
)

macro(xacro_expand input_path output_path)
    add_custom_command(OUTPUT "${output_path}"
        DEPENDS "${input_path}" ${ARGN}
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

# Create a standalone WAM URDF model.
xacro_expand("${PROJECT_SOURCE_DIR}/config/wam_params.urdf.xacro"
             "wam_params.urdf"
)
postprocess_urdf("${PROJECT_SOURCE_DIR}/robots/WAM_URDF.URDF"
                 "wam_params.urdf"
                 "wam_raw.urdf"
)
wrap_xacro("wam_raw.urdf"
           "${URDF_OUTPUT_DIR}/wam.urdf.xacro"
)

xacro_expand("${URDF_OUTPUT_DIR}/wam_standalone.urdf.xacro"
             "${URDF_OUTPUT_DIR}/wam.urdf"
)

add_custom_target(wam_urdf ALL
    DEPENDS #"${URDF_OUTPUT_DIR}/wam.urdf"
            "${URDF_OUTPUT_DIR}/wam.urdf.xacro"
    COMMENT "Generating WAM URDF"
    VERBATIM
)

# Create a standalone BarrettHand (BH280) URDF model.
xacro_expand("${PROJECT_SOURCE_DIR}/config/bh280_params.urdf.xacro"
             "bh280_params.urdf"
)
postprocess_urdf("${PROJECT_SOURCE_DIR}/robots/BHD280_URDF.URDF"
                 "bh280_params.urdf"
                 "bh280_raw.urdf"
)
wrap_xacro("bh280_raw.urdf"
           "${URDF_OUTPUT_DIR}/bh280.urdf.xacro"
)

xacro_expand("${URDF_OUTPUT_DIR}/bh280_standalone.urdf.xacro"
             "${URDF_OUTPUT_DIR}/bh280.urdf"
             # Additional dependencies.
             "${URDF_OUTPUT_DIR}/bh280.urdf.xacro"
)

add_custom_target(bh280_urdf ALL
    DEPENDS #"${URDF_OUTPUT_DIR}/bh280.urdf"
            "${URDF_OUTPUT_DIR}/bh280.urdf.xacro"
    COMMENT "Generating BH280 URDF"
    VERBATIM
)

# Create a WAM + BH280 model.
xacro_expand("${URDF_OUTPUT_DIR}/wam_bh280_standalone.urdf.xacro"
             "${URDF_OUTPUT_DIR}/wam_bh280.urdf"
             # Additional dependencies.
             "${URDF_OUTPUT_DIR}/bh280.urdf.xacro"
             "${URDF_OUTPUT_DIR}/wam.urdf.xacro"
)
add_custom_target(wam_bh280_urdf ALL
    DEPENDS #"${URDF_OUTPUT_DIR}/wam_bh280.urdf"
            "${URDF_OUTPUT_DIR}/wam_bh280_standalone.urdf.xacro"
    COMMENT "Generating WAM+BH280 URDF"
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
wrap_xacro("herb_base_raw.urdf"
           "${URDF_OUTPUT_DIR}/herb_base.urdf.xacro"
           # Additional dependencies.
           "${URDF_OUTPUT_DIR}/bh280.urdf.xacro"
)

if (NOT "${URDF_OUTPUT_DIR}" STREQUAL "${PROJECT_SOURCE_DIR}/robots")
    add_custom_command(OUTPUT "${URDF_OUTPUT_DIR}/herb.urdf.xacro"
        DEPENDS "${PROJECT_SOURCE_DIR}/robots/herb.urdf.xacro"
                "${URDF_OUTPUT_DIR}/herb_base.urdf.xacro"
                "${URDF_OUTPUT_DIR}/wam.urdf.xacro"
                "${URDF_OUTPUT_DIR}/bh280.urdf.xacro"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
                "${PROJECT_SOURCE_DIR}/robots/herb.urdf.xacro"
                "${URDF_OUTPUT_DIR}/herb.urdf.xacro"
    )
endif ()
xacro_expand("${URDF_OUTPUT_DIR}/herb.urdf.xacro"
             "${URDF_OUTPUT_DIR}/herb.urdf"
             # Additional dependencies.
             "${URDF_OUTPUT_DIR}/herb_base.urdf.xacro"
             "${URDF_OUTPUT_DIR}/bh280.urdf.xacro"
             "${URDF_OUTPUT_DIR}/wam.urdf.xacro"
)
add_custom_target(herb_urdf ALL
    DEPENDS "${URDF_OUTPUT_DIR}/herb.urdf"
            "${URDF_OUTPUT_DIR}/herb.urdf.xacro"
            "${URDF_OUTPUT_DIR}/herb_base.urdf.xacro"
    COMMENT "Generating HERB URDF"
    VERBATIM
)

# Generate the SRDF file.
xacro_expand("${PROJECT_SOURCE_DIR}/robots/herb.srdf.xacro"
             "${BASE_OUTPUT_DIR}/robots/herb.srdf")
add_custom_target(herb_srdf ALL
    DEPENDS "${URDF_OUTPUT_DIR}/herb.srdf"
    COMMENT "Generating HERB SRDF"
    VERBATIM
)

if (DEFINED CATKIN_TOPLEVEL OR (NOT ("$ENV{ROS_DISTRO}" STREQUAL "fuerte")))
    install(DIRECTORY "meshes"
                      "${URDF_OUTPUT_DIR}"
                      "${OPENRAVE_OUTPUT_DIR}"
                      "${PROJECT_SOURCE_DIR}/ordata"
        DESTINATION "${CATKIN_PACKAGE_SHARE_DESTINATION}"
        PATTERN ".svn" EXCLUDE
    )
endif ()
