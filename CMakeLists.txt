cmake_minimum_required(VERSION 2.8.3)
project(herb_description)

find_package(catkin REQUIRED)
catkin_package()

option(BUILD_ALL_HERB_MODELS "Build all variations of the HERB models" OFF)

macro(build_xacro infile outfile xacro_args)
    # Call out to xacro to get dependencies
    execute_process(COMMAND ${CATKIN_ENV} rosrun xacro xacro --deps ${infile}
        ERROR_VARIABLE _xacro_err_ignore
        OUTPUT_VARIABLE _xacro_deps_result
        OUTPUT_STRIP_TRAILING_WHITESPACE)

    separate_arguments(_xacro_deps_result)
    separate_arguments(xacro_args)

    # Process xacro into final output
    add_custom_command(OUTPUT ${outfile}
        COMMENT "Generating ${outfile}"
        COMMAND ${CATKIN_ENV} rosrun xacro xacro
        -o ${outfile} ${infile} ${_xacro_deps_result} ${xacro_args}
        DEPENDS ${infile} ${_xacro_deps_result}
        VERBATIM)
endmacro(build_xacro)


set(ROBOTS_SRC_DIR "${CMAKE_CURRENT_SOURCE_DIR}/robots")
set(BASE_OUTPUT_DIR "${CATKIN_DEVEL_PREFIX}/${CATKIN_PACKAGE_SHARE_DESTINATION}")
set(ROBOTS_OUTPUT_DIR "${BASE_OUTPUT_DIR}/robots")
file(MAKE_DIRECTORY ${ROBOTS_OUTPUT_DIR})

# Build component parts
set(WAM_STANDALONE_URDF_XACRO "${ROBOTS_SRC_DIR}/wam_standalone.urdf.xacro")
set(WAM_STANDALONE_URDF "${ROBOTS_OUTPUT_DIR}/wam.urdf")

set(BH280_STANDALONE_URDF_XACRO "${ROBOTS_SRC_DIR}/bh280_standalone.urdf.xacro")
set(BH280_STANDALONE_URDF "${ROBOTS_OUTPUT_DIR}/bh280.urdf")

set(WAM_BH280_STANDALONE_URDF_XACRO "${ROBOTS_SRC_DIR}/wam_bh280_standalone.urdf.xacro")
set(WAM_BH280_STANDALONE_URDF "${ROBOTS_OUTPUT_DIR}/wam_bh280.urdf")

build_xacro(${WAM_STANDALONE_URDF_XACRO} ${WAM_STANDALONE_URDF} "")
build_xacro(${BH280_STANDALONE_URDF_XACRO} ${BH280_STANDALONE_URDF} "")
build_xacro(${WAM_BH280_STANDALONE_URDF_XACRO} ${WAM_BH280_STANDALONE_URDF} "")

# HERB model matrix
#
# | LEFT  | RIGHT |
# |-------|-------|
# | BH280 | BH280 |
# | BH280 | None  |
# | None  | BH280 |
# | None  | None  |

# Default HERB (two BH280 hands)
set(HERB_URDF_XACRO "${ROBOTS_SRC_DIR}/herb.urdf.xacro")
set(HERB_URDF "${ROBOTS_OUTPUT_DIR}/herb.urdf")

set(HERB_SRDF_XACRO "${ROBOTS_SRC_DIR}/herb.srdf.xacro")
set(HERB_SRDF "${ROBOTS_OUTPUT_DIR}/herb.srdf")

set(full_herb_args "left_bh280:=true" "right_bh280:=true")
build_xacro(${HERB_URDF_XACRO} ${HERB_URDF} "${full_herb_args}")
build_xacro(${HERB_SRDF_XACRO} ${HERB_SRDF} "")

if(BUILD_ALL_HERB_MODELS)

    # HERB with no right hand
    set(HERB_NO_RIGHT_HAND_URDF "${ROBOTS_OUTPUT_DIR}/herb_bh280_left_no_right.urdf")
    set(HERB_NO_RIGHT_HAND_SRDF "${ROBOTS_OUTPUT_DIR}/herb_bh280_left_no_right.srdf")

    set(no_right_herb_args "left_bh280:=true" "right_bh280:=false")
    build_xacro(${HERB_URDF_XACRO} ${HERB_NO_RIGHT_HAND_URDF} "${no_right_herb_args}")
    build_xacro(${HERB_SRDF_XACRO} ${HERB_NO_RIGHT_HAND_SRDF} "right_hand:=false")

    # HERB with no left hand
    set(HERB_NO_LEFT_HAND_URDF "${ROBOTS_OUTPUT_DIR}/herb_no_left_bh280_right.urdf")
    set(HERB_NO_LEFT_HAND_SRDF "${ROBOTS_OUTPUT_DIR}/herb_no_left_bh280_right.srdf")

    set(no_left_herb_args "left_bh280:=false" "right_bh280:=true")
    build_xacro(${HERB_URDF_XACRO} ${HERB_NO_LEFT_HAND_URDF} "${no_left_herb_args}")
    build_xacro(${HERB_SRDF_XACRO} ${HERB_NO_LEFT_HAND_SRDF} "left_hand:=false")

    # HERB with no hands
    set(HERB_NO_HANDS_URDF "${ROBOTS_OUTPUT_DIR}/herb_no_left_no_right.urdf")
    set(HERB_NO_HANDS_SRDF "${ROBOTS_OUTPUT_DIR}/herb_no_left_no_right.srdf")

    set(no_right_herb_args "left_bh280:=false" "right_bh280:=false")
    build_xacro(${HERB_URDF_XACRO} ${HERB_NO_HANDS_URDF} "${no_hands_herb_args}")
    set(no_hands_herb_args "left_hand:=false" "right_hand:=false")
    build_xacro(${HERB_SRDF_XACRO} ${HERB_NO_HANDS_SRDF} "${no_hands_herb_args}")

endif(BUILD_ALL_HERB_MODELS)

list(APPEND CORE_DESCRIPTION_FILES
  ${WAM_STANDALONE_URDF}
  ${BH280_STANDALONE_URDF}
  ${WAM_BH280_STANDALONE_URDF}
  ${HERB_URDF}
  ${HERB_SRDF}
)

# add target to actually cause generation
if(BUILD_ALL_HERB_MODELS)
    list(APPEND EXTRA_DESCRIPTION_FILES
    ${HERB_NO_LEFT_HAND_URDF}
    ${HERB_NO_LEFT_HAND_SRDF}
    ${HERB_NO_RIGHT_HAND_URDF}
    ${HERB_NO_RIGHT_HAND_SRDF}
    ${HERB_NO_HANDS_URDF}
    ${HERB_NO_HANDS_SRDF}
    )

    add_custom_target(description_files ALL DEPENDS
    ${CORE_DESCRIPTION_FILES}
    ${EXTRA_DESCRIPTION_FILES})
else()
    add_custom_target(description_files ALL DEPENDS
    ${CORE_DESCRIPTION_FILES})
endif(BUILD_ALL_HERB_MODELS)

install(DIRECTORY DESTINATION "${CATKIN_PACKAGE_SHARE_DESTINATION}/robots")
install(FILES
  ${DESCRIPTION_FILES}
  DESTINATION "${CATKIN_PACKAGE_SHARE_DESTINATION}/robots")

install(DIRECTORY meshes
  DESTINATION "${CATKIN_PACKAGE_SHARE_DESTINATION}")
