
# 获取指定目录下的所有子目录
macro(get_subdirectories target_dir subdirs_var)
    file(GLOB children RELATIVE ${target_dir} ${target_dir}/*)
    set(dirlist "")
    foreach(child ${children})
        if(IS_DIRECTORY ${target_dir}/${child})
            list(APPEND dirlist ${child})
        endif()
    endforeach()
    set(${subdirs_var} ${dirlist})
endmacro()

# 获取指定目录下的所有源文件
macro(get_source_files target_dir sources_var)
    file(GLOB_RECURSE sources RELATIVE ${CMAKE_SOURCE_DIR} ${target_dir}/*.cpp ${target_dir}/*.h)
    set(${sources_var} ${sources})
endmacro()

# 获取指定目录下的所有头文件
macro(get_header_files target_dir headers_var)
    file(GLOB_RECURSE headers RELATIVE ${CMAKE_SOURCE_DIR} ${target_dir}/*.h)
    set(${headers_var} ${headers})
endmacro()
