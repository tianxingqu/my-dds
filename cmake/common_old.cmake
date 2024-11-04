
# 获取根目录下的path 当前路径以及所有子目录下的所有源文件头文件 打包成SUBDIR_SOURCES，并且添加到GLOBAL_SOURCES
# auto list all (.h and .cpp) file in path, path is absolute path relative to ${CMAKE_CURRENT_SOURCE_DIR}
MACRO(SUBDIR_FILE_LIST path)
    MESSAGE(STATUS "**************" ${path})

    string(REPLACE "/" ";" dirname ${path})
    list(GET dirname 0 dir)
    list(GET dirname 1 subdir)
    MESSAGE(STATUS "Subdir of `" ${dir} "` : " ${subdir})

    FILE(GLOB_RECURSE SUBDIR_SOURCES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
        ${path}/*.h
        ${path}/*.hpp
        ${path}/*.cpp
        ${path}/.cc
        ${path}/*.c
    ) # 将path目录以及所有子目录的文件均打包成SUBDIR_SOURCES
    source_group(${path} FILES ${SUBDIR_SOURCES})   # 按path进行分组
    MESSAGE(STATUS "SUBDIR SOURCES: ${SUBDIR_SOURCES}")
    list(APPEND GLOBAL_SOURCES ${SUBDIR_SOURCES})
ENDMACRO()

# 调用宏
# SUBDIRFILELIST(base)    # 将src/base目录以及子目录下的所有源文件头文件均打包并且添加到GLOBAL_SOURCES
# SUBDIRFILELIST(model1)  # src/model1目录以及所有子目录

# 将根目录下的curdir目录下所有除(build 、 utest 、 .* 、 main)的子目录 分别打包源文件和头文件并添加到GLOBAL_SOURCES
# auto list all directory, except build or utest or .* or main
set(SUB_DIR "")
MACRO(SUBDIR_LIST curdir SUB_DIR)  # 定义宏，参数result--源文件和头文件打包 curdir--当前目录

    SET(curdir_full_path ${CMAKE_CURRENT_SOURCE_DIR}/${curdir})
    # 将curdir目录下的所有文件、文件夹 打包成children
    FILE(GLOB children RELATIVE ${curdir_full_path} CONFIGURE_DEPENDS ${curdir_full_path}/*)
    MESSAGE(STATUS "Handle Current DIR: " ${curdir_full_path})
    # 遍历children 将子目录中需要编译的文件添加到dirlist目录
    FOREACH(child ${children})
        IF(IS_DIRECTORY ${curdir_full_path}/${child})  # 是目录
            list(APPEND SUB_DIR ${curdir}/${child})
        ENDIF()
    ENDFOREACH()
ENDMACRO()
