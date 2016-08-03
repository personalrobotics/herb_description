cmake_minimum_required(VERSION 2.8.3)
project(herb_description)

find_package(catkin REQUIRED)
catkin_package()


macro(build_xacro infile outfile argstring)
    # Call out to xacro to get dependencies
    execute_process(COMMAND ${CATKIN_ENV} rosrun xacro xacro --deps ${infile}
    ERROR_VARIABLE _xacro_err_ignore
    OUTPUT_VARIABLE _xacro_deps_result
    OUTPUT_STRIP_TRAILING_WHITESPACE)

    separate_arguments(_xacro_deps_result)

    add_custom_command(OUTPUT ${outfile}
    COMMENT "Generating ${outfile}"
    COMMAND ${CATKIN_ENV} rosrun xacro xacro
    ARGS -o ${outfile} ${infile} ${_xacro_deps_result} ${argstring}
    DEPENDS ${infile} ${_xacro_deps_result})
endmacro(build_xacro)


set(ROBOTS_SRC_DIR "${CMAKE_CURRENT_SOURCE_DIR}/robots")
set(BASE_OUTPUT_DIR "${CATKIN_DEVEL_PREFIX}/${CATKIN_PACKAGE_SHARE_DESTINATION}")
set(ROBOTS_OUTPUT_DIR "${BASE_OUTPUT_DIR}/robots")
file(MAKE_DIRECTORY ${ROBOTS_OUTPUT_DIR})


set(WAM_STANDALONE_URDF_XACRO "${ROBOTS_SRC_DIR}/wam_standalone.urdf.xacro")
set(WAM_STANDALONE_URDF "${ROBOTS_OUTPUT_DIR}/wam.urdf")

set(BH280_STANDALONE_URDF_XACRO "${ROBOTS_SRC_DIR}/bh280_standalone.urdf.xacro")
set(BH280_STANDALONE_URDF "${ROBOTS_OUTPUT_DIR}/bh280.urdf")

set(WAM_BH280_STANDALONE_URDF_XACRO "${ROBOTS_SRC_DIR}/wam_bh280_standalone.urdf.xacro")
set(WAM_BH280_STANDALONE_URDF "${ROBOTS_OUTPUT_DIR}/wam_bh280.urdf")

set(HERB_URDF_XACRO "${ROBOTS_SRC_DIR}/herb.urdf.xacro")
set(HERB_URDF "${ROBOTS_OUTPUT_DIR}/herb.urdf")

set(HERB_SRDF_XACRO "${ROBOTS_SRC_DIR}/herb.srdf.xacro")
set(HERB_SRDF "${ROBOTS_OUTPUT_DIR}/herb.srdf")


build_xacro(${WAM_STANDALONE_URDF_XACRO} ${WAM_STANDALONE_URDF} "")
build_xacro(${BH280_STANDALONE_URDF_XACRO} ${BH280_STANDALONE_URDF} "")
build_xacro(${WAM_BH280_STANDALONE_URDF_XACRO} ${WAM_BH280_STANDALONE_URDF} "")
build_xacro(${HERB_URDF_XACRO} ${HERB_URDF} "")
build_xacro(${HERB_SRDF_XACRO} ${HERB_SRDF} "")


list(APPEND DESCRIPTION_FILES
  ${WAM_STANDALONE_URDF}
  ${BH280_STANDALONE_URDF}
  ${WAM_BH280_STANDALONE_URDF}
  ${HERB_URDF}
  ${HERB_SRDF}
)

# add target to actually cause generation
add_custom_target(description_files ALL DEPENDS
  ${DESCRIPTION_FILES})

install(DIRECTORY DESTINATION "${CATKIN_PACKAGE_SHARE_DESTINATION}/robots")
install(FILES
  ${DESCRIPTION_FILES}
  DESTINATION "${CATKIN_PACKAGE_SHARE_DESTINATION}/robots")

install(DIRECTORY meshes
  DESTINATION "${CATKIN_PACKAGE_SHARE_DESTINATION}")
