cmake_minimum_required(VERSION 2.8.3)
project(herb_description)

find_package(catkin REQUIRED)
catkin_package()

option(BUILD_ALL_HERB_MODELS "Build all variations of the HERB models" ON)

function(build_xacro infile outfile xacro_args)
  # Call out to xacro to get dependencies
  execute_process(COMMAND ${CATKIN_ENV} rosrun xacro xacro --deps "${infile}"
    ERROR_VARIABLE _xacro_err_ignore
    OUTPUT_VARIABLE _xacro_deps_result
    OUTPUT_STRIP_TRAILING_WHITESPACE)

  separate_arguments(_xacro_deps_result)
  separate_arguments(xacro_args)

  # Process xacro into final output
  add_custom_command(OUTPUT "${outfile}"
    COMMENT "Generating ${outfile}"
    COMMAND ${CATKIN_ENV} rosrun xacro xacro
    -o "${outfile}" "${infile}" ${_xacro_deps_result} ${xacro_args}
    DEPENDS "${infile}" ${_xacro_deps_result}
    VERBATIM)
endfunction(build_xacro)

macro(append_hand_flags hand hand_option urdf_args srdf_args)
  if(${hand_option} STREQUAL "bh280")
    list(APPEND ${urdf_args} "${hand}_bh280:=true")
  endif()
  if(${hand_option} STREQUAL "bh282")
    list(APPEND ${urdf_args} "${hand}_bh282:=true")
    list(APPEND ${srdf_args} "${hand}_perception:=true")
  endif()
  if(NOT ${hand_option} STREQUAL "no")
    list(APPEND ${srdf_args} "${hand}_hand:=true")
  endif()
endmacro(append_hand_flags)


set(ROBOTS_SRC_DIR "${CMAKE_CURRENT_SOURCE_DIR}/robots")
set(BASE_OUTPUT_DIR "${CATKIN_DEVEL_PREFIX}/${CATKIN_PACKAGE_SHARE_DESTINATION}")
set(ROBOTS_OUTPUT_DIR "${BASE_OUTPUT_DIR}/robots")
file(MAKE_DIRECTORY ${ROBOTS_OUTPUT_DIR})

# Build component parts
set(WAM_STANDALONE_URDF_XACRO "${ROBOTS_SRC_DIR}/wam_standalone.urdf.xacro")
set(WAM_STANDALONE_URDF "${ROBOTS_OUTPUT_DIR}/wam.urdf")

set(BH280_STANDALONE_URDF_XACRO "${ROBOTS_SRC_DIR}/bh280_standalone.urdf.xacro")
set(BH280_STANDALONE_URDF "${ROBOTS_OUTPUT_DIR}/bh280.urdf")
set(BH280_STANDALONE_SRDF_XACRO "${ROBOTS_SRC_DIR}/bh280_standalone.srdf.xacro")
set(BH280_STANDALONE_SRDF "${ROBOTS_OUTPUT_DIR}/bh280.srdf")

set(BH282_STANDALONE_URDF_XACRO "${ROBOTS_SRC_DIR}/bh282_standalone.urdf.xacro")
set(BH282_STANDALONE_URDF "${ROBOTS_OUTPUT_DIR}/bh282.urdf")
set(BH282_STANDALONE_SRDF_XACRO "${ROBOTS_SRC_DIR}/bh282_standalone.srdf.xacro")
set(BH282_STANDALONE_SRDF "${ROBOTS_OUTPUT_DIR}/bh282.srdf")

set(WAM_BH280_STANDALONE_URDF_XACRO "${ROBOTS_SRC_DIR}/wam_bh280_standalone.urdf.xacro")
set(WAM_BH280_STANDALONE_URDF "${ROBOTS_OUTPUT_DIR}/wam_bh280.urdf")

set(WAM_BH282_STANDALONE_URDF_XACRO "${ROBOTS_SRC_DIR}/wam_bh282_standalone.urdf.xacro")
set(WAM_BH282_STANDALONE_URDF "${ROBOTS_OUTPUT_DIR}/wam_bh282.urdf")

build_xacro(${WAM_STANDALONE_URDF_XACRO} ${WAM_STANDALONE_URDF} "")
build_xacro(${BH280_STANDALONE_URDF_XACRO} ${BH280_STANDALONE_URDF} "")
build_xacro(${BH280_STANDALONE_SRDF_XACRO} ${BH280_STANDALONE_SRDF} "")
build_xacro(${BH282_STANDALONE_URDF_XACRO} ${BH282_STANDALONE_URDF} "")
build_xacro(${BH282_STANDALONE_SRDF_XACRO} ${BH282_STANDALONE_SRDF} "")
build_xacro(${WAM_BH280_STANDALONE_URDF_XACRO} ${WAM_BH280_STANDALONE_URDF} "")
build_xacro(${WAM_BH282_STANDALONE_URDF_XACRO} ${WAM_BH282_STANDALONE_URDF} "")

# HERB model matrix
#
# | LEFT  | RIGHT |
# |-------|-------|
# | BH280 | BH280 | # impossible
# | BH280 | None  |
# | BH280 | BH282 | # DEFAULT
# | None  | None  |
# | None  | BH280 |
# | None  | BH282 |
# | BH282 | BH282 | # impossible
# | BH282 | BH280 |
# | BH282 | None  |

set(HERB_HAND_OPTIONS "bh280" "bh282" "no")

# Default HERB (two BH280 hands)
set(HERB_URDF_XACRO "${ROBOTS_SRC_DIR}/herb.urdf.xacro")
set(HERB_URDF "${ROBOTS_OUTPUT_DIR}/herb.urdf")

set(HERB_SRDF_XACRO "${ROBOTS_SRC_DIR}/herb.srdf.xacro")
set(HERB_SRDF "${ROBOTS_OUTPUT_DIR}/herb.srdf")

set(FULL_HERB_URDF_ARGS "left_bh280:=true" "right_bh282:=true")
build_xacro(${HERB_URDF_XACRO} ${HERB_URDF} "${FULL_HERB_URDF_ARGS}")
set(FULL_HERB_SRDF_ARGS "left_hand:=true" "right_hand:=true" "right_perception:=true")
build_xacro(${HERB_SRDF_XACRO} ${HERB_SRDF} "${FULL_HERB_SRDF_ARGS}")

list(APPEND CORE_DESCRIPTION_FILES
  ${WAM_STANDALONE_URDF}
  ${BH280_STANDALONE_URDF}
  ${BH280_STANDALONE_SRDF}
  ${BH282_STANDALONE_URDF}
  ${BH282_STANDALONE_SRDF}
  ${WAM_BH280_STANDALONE_URDF}
  ${WAM_BH282_STANDALONE_URDF}
  ${HERB_URDF}
  ${HERB_SRDF}
  )


if(BUILD_ALL_HERB_MODELS)
  set(EXTRA_DESCRIPTION_FILES)

  # Generate combinatorial hand option models
  foreach(LEFT_HAND ${HERB_HAND_OPTIONS})
    foreach(RIGHT_HAND ${HERB_HAND_OPTIONS})

      # Default configure is named differently and handled outside loop.
      set(IS_DEFAULT_HAND_CASE (${LEFT_HAND} STREQUAL "bh280" AND ${RIGHT_HAND} STREQUAL "bh282"))
      # We only have one of each type of hand
      set(IS_DUAL_BH280_CASE (${LEFT_HAND} STREQUAL "bh280" AND ${RIGHT_HAND} STREQUAL "bh280"))
      set(IS_DUAL_BH282_CASE (${LEFT_HAND} STREQUAL "bh282" AND ${RIGHT_HAND} STREQUAL "bh282"))

      if(NOT (${IS_DEFAULT_HAND_CASE} OR ${IS_DUAL_BH280_CASE} OR ${IS_DUAL_BH282_CASE}))
        set(HERB_URDF_OUTPUT "${ROBOTS_OUTPUT_DIR}/herb_${LEFT_HAND}_left_${RIGHT_HAND}_right.urdf")
        set(HERB_SRDF_OUTPUT "${ROBOTS_OUTPUT_DIR}/herb_${LEFT_HAND}_left_${RIGHT_HAND}_right.srdf")

        set(HERB_URDF_ARGS)
        set(HERB_SRDF_ARGS)

        append_hand_flags(left LEFT_HAND HERB_URDF_ARGS HERB_SRDF_ARGS)
        append_hand_flags(right RIGHT_HAND HERB_URDF_ARGS HERB_SRDF_ARGS)

        build_xacro(${HERB_URDF_XACRO} ${HERB_URDF_OUTPUT} "${HERB_URDF_ARGS}")
        build_xacro(${HERB_SRDF_XACRO} ${HERB_SRDF_OUTPUT} "${HERB_SRDF_ARGS}")

        list(APPEND EXTRA_DESCRIPTION_FILES
          ${HERB_URDF_OUTPUT}
          ${HERB_SRDF_OUTPUT})
      endif()

    endforeach(RIGHT_HAND)
  endforeach(LEFT_HAND)

  # add target to actually cause generation
  add_custom_target(description_files ALL DEPENDS
    ${CORE_DESCRIPTION_FILES}
    ${EXTRA_DESCRIPTION_FILES})

else()

  # add target to actually cause generation
  add_custom_target(description_files ALL DEPENDS
    ${CORE_DESCRIPTION_FILES})

endif(BUILD_ALL_HERB_MODELS)

install(DIRECTORY DESTINATION "${CATKIN_PACKAGE_SHARE_DESTINATION}/robots")
install(FILES
  ${DESCRIPTION_FILES}
  DESTINATION "${CATKIN_PACKAGE_SHARE_DESTINATION}/robots")

install(DIRECTORY meshes
  DESTINATION "${CATKIN_PACKAGE_SHARE_DESTINATION}")
