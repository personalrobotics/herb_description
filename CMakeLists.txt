cmake_minimum_required(VERSION 2.6)
project(herb_description)

find_package(catkin REQUIRED xacro)
catkin_package()

set(COMMAND_PARAMS_POSTPROCESS ${PROJECT_SOURCE_DIR}/scripts/postprocess_params.py)
set(COMMAND_XACRO_POSTPROCESS ${PROJECT_SOURCE_DIR}/scripts/postprocess_xacro.py)

macro(postprocess_urdf input_path params_path output_path)
    add_custom_command(
        OUTPUT  ${output_path}
        DEPENDS ${COMMAND_PARAMS_POSTPROCESS} ${input_path} ${params_path}
        COMMAND ${COMMAND_PARAMS_POSTPROCESS} ${input_path} ${params_path} ${output_path}
    )
endmacro()

macro(wrap_xacro input_path output_path)
    get_filename_component(xacro_name "${output_path}" NAME_WE)
    add_custom_command(
        OUTPUT  ${output_path}
        DEPENDS ${COMMAND_XACRO_POSTPROCESS} ${input_path}
        COMMAND ${COMMAND_XACRO_POSTPROCESS}
                --name=${xacro_name} --package=herb_description --collision_meshes=True
                ${input_path} ${output_path}
    )
endmacro()

# Generate xacro files for the individual components.
# TODO: Add appropriate dependencies s.t. these directories are automatically created.
file(MAKE_DIRECTORY config)
file(MAKE_DIRECTORY robots)

# Create a standalone WAM URDF model.
xacro_add_xacro_file(${PROJECT_SOURCE_DIR}/config/wam_params.urdf.xacro config/wam_params.urdf)
postprocess_urdf(${PROJECT_SOURCE_DIR}/robots/WAM_URDF.URDF config/wam_params.urdf wam_raw.urdf)
wrap_xacro(wam_raw.urdf robots/wam.urdf.xacro)
xacro_add_xacro_file(robots/wam.urdf.xacro robots/wam.urdf)
add_custom_target(wam_urdf ALL DEPENDS robots/wam.urdf robots/wam.urdf.xacro)

# Create a standalone BarrettHand (BH280) URDF model.
xacro_add_xacro_file(${PROJECT_SOURCE_DIR}/config/bh280_params.urdf.xacro config/bh280_params.urdf)
postprocess_urdf(${PROJECT_SOURCE_DIR}/robots/BHD280_URDF.URDF config/bh280_params.urdf bh280_raw.urdf)
wrap_xacro(bh280_raw.urdf robots/bh280.urdf.xacro)
xacro_add_xacro_file(robots/bh280.urdf.xacro robots/bh280.urdf)
add_custom_target(bh280_urdf ALL DEPENDS robots/bh280.urdf robots/bh280.urdf.xacro)

# Create the HERB URDF model.
xacro_add_xacro_file(${PROJECT_SOURCE_DIR}/config/herb_params.urdf.xacro config/herb_params.urdf)
postprocess_urdf(${PROJECT_SOURCE_DIR}/robots/HERB_BASES_URDF.URDF config/herb_params.urdf herb_raw.urdf)
wrap_xacro(herb_base_raw.urdf herb_base.urdf.xacro)
xacro_add_xacro_file(${PROJECT_SOURCE_DIR}/robots/herb.urdf.xacro robots/herb.urdf)
add_custom_target(herb_urdf ALL DEPENDS robots/herb.urdf)

