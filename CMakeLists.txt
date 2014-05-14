cmake_minimum_required(VERSION 2.6)
project(herb_description)

find_package(catkin REQUIRED xacro)
catkin_package()

set(COMMAND_PARAMS_POSTPROCESS ${PROJECT_SOURCE_DIR}/scripts/postprocess_params.py)
set(COMMAND_XACRO_POSTPROCESS ${PROJECT_SOURCE_DIR}/scripts/postprocess_xacro.py)

macro(postprocess_urdf output_path input_path params_path)
    add_custom_command(
        OUTPUT  ${output_path}
        DEPENDS ${COMMAND_PARAMS_POSTPROCESS}
                ${PROJECT_SOURCE_DIR}/robots/${input_path}
                ${PROJECT_SOURCE_DIR}/config/${params_path}
        COMMAND ${COMMAND_PARAMS_POSTPROCESS}
                ${PROJECT_SOURCE_DIR}/robots/${input_path}
                ${PROJECT_SOURCE_DIR}/config/${params_path}
                ${output_path}
    )
endmacro()

macro(wrap_xacro output_path input_path)
    get_filename_component(xacro_name "${output_path}" NAME_WE)
    add_custom_command(
        OUTPUT  ${output_path}
        DEPENDS ${COMMAND_XACRO_POSTPROCESS}
                ${PROJECT_SOURCE_DIR}/robots/${input_path}
        COMMAND ${COMMAND_XACRO_POSTPROCESS}
                --name=${xacro_name} --package=herb_description --collision_meshes=True
                ${PROJECT_SOURCE_DIR}/robots/${input_path}
                ${output_path}
    )
endmacro()

# Generate xacro files for the individual components.
postprocess_urdf(wam_raw.urdf WAM_URDF.URDF wam_params.urdf)
postprocess_urdf(bh280_raw.urdf BHD280_URDF.URDF bh280_params.urdf)
postprocess_urdf(herb_base_raw.urdf HERB_BASE_URDF.URDF herb_params.urdf)
wrap_xacro(wam.urdf.xacro wam_raw.urdf)
wrap_xacro(bh280.urdf.xacro bh280_raw.urdf)
wrap_xacro(herb_base.urdf.xacro herb_base_raw.urdf)

# Glue the components together into HERB.
xacro_add_xacro_file(${PROJECT_SOURCE_DIR}/robots/herb.urdf.xacro herb.urdf)

# Generate standalone WAM and BH280 models.
xacro_add_xacro_file(wam.urdf.xacro wam.urdf)
xacro_add_xacro_file(bh280.urdf.xacro bh280.urdf)

add_custom_target(wam_urdf ALL DEPENDS wam.urdf.xacro wam.urdf)
add_custom_target(bh280_urdf ALL DEPENDS bh280.urdf.xacro bh280.urdf)
add_custom_target(herb_urdf ALL DEPENDS herb.urdf)
