##
# @Author: Qiang Wang
# @date: 2022-07-26 17:18:31
# @last_author: Qiang Wang (wangq@yusur.tech)
# @last_edit_time: 2022-07-26 17:18:31
##
##
# @brief: Utilities for CMakeLists
# @Company: YUSUR. Copyright(c) All rights reserved
# @version:
# @Author: Jiacheng Pang
# @Date: 2021-01-29 10:08:33
# @last_edit_time: 2021-09-01 17:17:37
# @last_author: Qiang Wang (wangq@yusur.tech)
##

#### get git hash for PROJECT_VERSION_PATCH
macro(get_git_hash _git_hash)
    find_package(Git QUIET)
    if(GIT_FOUND)
      execute_process(
        COMMAND ${GIT_EXECUTABLE} log -1 --pretty=format:%h
        OUTPUT_VARIABLE ${_git_hash}
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET
        WORKING_DIRECTORY
          ${CMAKE_CURRENT_SOURCE_DIR}
        )
    else()
        message(WARNING "Git hash not found.")
    endif()
endmacro()

#### process git hash to fit the version format requirement
#### patch number is the first four characters of git hash, where letters are replaced
#### with the numeric values (char - "a")
macro(get_version_number _version_number)
    set(GIT_HASH "")
    set(GIT_HASH_CHAR "")
    set(GIT_COMP 0)
    set(GIT_LOOP_COUNT 0)
    set(RESULT "1.0.")
    get_git_hash(GIT_HASH)
    message(STATUS "Git hash is ${GIT_HASH}")

    foreach(i RANGE 3)
        string(SUBSTRING ${GIT_HASH} ${i} 1 GIT_HASH_CHAR)
        string(COMPARE LESS ${GIT_HASH_CHAR} "a" GIT_COMP)
        if(GIT_COMP)
            string(APPEND RESULT ${GIT_HASH_CHAR})
        else()
            set(GIT_LOOP_COUNT 0)
            foreach(letter a b c d e f)
                string(COMPARE EQUAL ${GIT_HASH_CHAR} ${letter} GIT_COMP)
                if (GIT_COMP)
                    string(APPEND RESULT ${GIT_LOOP_COUNT})
                    break()
                else()
                    math(EXPR GIT_LOOP_COUNT "${GIT_LOOP_COUNT} + 1")
                endif()
            endforeach(letter)
        endif()
    endforeach(i)
    set(${_version_number} ${RESULT})
    message(STATUS "Project version is ${RESULT}")
endmacro()

function(get_target_triplet target_triplet)
    #### Get target triplet architecture, such as `x86`、`x64` etc, save to CURRENT_TARGET_TRIPLET_ARCH
    if(CURRENT_TARGET_TRIPLET_ARCH)
    elseif(CMAKE_GENERATOR_PLATFORM MATCHES "^[Ww][Ii][Nn]32$")
        set(CURRENT_TARGET_TRIPLET_ARCH x86)
    elseif(CMAKE_GENERATOR_PLATFORM MATCHES "^[Xx]64$")
        set(CURRENT_TARGET_TRIPLET_ARCH x64)
    elseif(CMAKE_GENERATOR_PLATFORM MATCHES "^[Aa][Rr][Mm]$")
        set(CURRENT_TARGET_TRIPLET_ARCH arm)
    elseif(CMAKE_GENERATOR_PLATFORM MATCHES "^[Aa][Rr][Mm]64$")
        set(CURRENT_TARGET_TRIPLET_ARCH arm64)
    else()
        if(CMAKE_GENERATOR MATCHES "^Visual Studio 14 2015 Win64$")
            set(CURRENT_TARGET_TRIPLET_ARCH x64)
        elseif(CMAKE_GENERATOR MATCHES "^Visual Studio 14 2015 ARM$")
            set(CURRENT_TARGET_TRIPLET_ARCH arm)
        elseif(CMAKE_GENERATOR MATCHES "^Visual Studio 14 2015$")
            set(CURRENT_TARGET_TRIPLET_ARCH x86)
        elseif(CMAKE_GENERATOR MATCHES "^Visual Studio 15 2017 Win64$")
            set(CURRENT_TARGET_TRIPLET_ARCH x64)
        elseif(CMAKE_GENERATOR MATCHES "^Visual Studio 15 2017 ARM$")
            set(CURRENT_TARGET_TRIPLET_ARCH arm)
        elseif(CMAKE_GENERATOR MATCHES "^Visual Studio 15 2017$")
            set(CURRENT_TARGET_TRIPLET_ARCH x86)
        elseif(CMAKE_GENERATOR MATCHES "^Visual Studio 16 2019$")
            set(CURRENT_TARGET_TRIPLET_ARCH x64)
        else()
            find_program(VS_CL cl)
            if(VS_CL MATCHES "amd64/cl.exe$" OR VS_CL MATCHES "x64/cl.exe$")
                set(CURRENT_TARGET_TRIPLET_ARCH x64)
            elseif(VS_CL MATCHES "arm/cl.exe$")
                set(CURRENT_TARGET_TRIPLET_ARCH arm)
            elseif(VS_CL MATCHES "arm64/cl.exe$")
                set(CURRENT_TARGET_TRIPLET_ARCH arm64)
            elseif(VS_CL MATCHES "bin/cl.exe$" OR VS_CL MATCHES "x86/cl.exe$")
                set(CURRENT_TARGET_TRIPLET_ARCH x86)
            elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin" AND DEFINED CMAKE_SYSTEM_NAME AND NOT CMAKE_SYSTEM_NAME STREQUAL "Darwin")
                list(LENGTH CMAKE_OSX_ARCHITECTURES arch_count)
                if(arch_count EQUAL 0)
                    message(WARNING "Unable to determine target architecture. "
                                    "Consider providing a value for the CMAKE_OSX_ARCHITECTURES cache variable. ")
                    return()
                else()
                    if(arch_count GREATER 1)
                        message(WARNING "Detected more than one target architecture. Using the first one.")
                    endif()
                    list(GET CMAKE_OSX_ARCHITECTURES 0 target_arch)
                    if(target_arch STREQUAL arm64)
                        set(CURRENT_TARGET_TRIPLET_ARCH arm64)
                    elseif(target_arch STREQUAL arm64s)
                        set(CURRENT_TARGET_TRIPLET_ARCH arm64s)
                    elseif(target_arch STREQUAL armv7s)
                        set(CURRENT_TARGET_TRIPLET_ARCH armv7s)
                    elseif(target_arch STREQUAL armv7)
                        set(CURRENT_TARGET_TRIPLET_ARCH arm)
                    elseif(target_arch STREQUAL x86_64)
                        set(CURRENT_TARGET_TRIPLET_ARCH x64)
                    elseif(target_arch STREQUAL i386)
                        set(CURRENT_TARGET_TRIPLET_ARCH x86)
                    else()
                        message(WARNING "Unable to determine target architecture.")
                        return()
                    endif()
                endif()
            elseif(CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "x86_64")
                set(CURRENT_TARGET_TRIPLET_ARCH x64)
            else()
                if( _CMAKE_IN_TRY_COMPILE )
                    message(STATUS "Unable to determine target architecture.")
                else()
                    message(WARNING "Unable to determine target architecture.")
                endif()
                return()
            endif()
        endif()
    endif()
    #### End - Get target triplet architecture

    #### Get target triplet platform, such as `Windows`、`Linux` etc, save to CURRENT_TARGET_TRIPLET_PLATFORM
    if(CMAKE_SYSTEM_NAME STREQUAL "WindowsStore" OR CMAKE_SYSTEM_NAME STREQUAL "WindowsPhone")
        set(CURRENT_TARGET_TRIPLET_PLATFORM uwp)
    elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux" OR (NOT CMAKE_SYSTEM_NAME AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux"))
        set(CURRENT_TARGET_TRIPLET_PLATFORM linux)
    elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin" OR (NOT CMAKE_SYSTEM_NAME AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin"))
        set(CURRENT_TARGET_TRIPLET_PLATFORM osx)
    elseif(CMAKE_SYSTEM_NAME STREQUAL "iOS")
        set(CURRENT_TARGET_TRIPLET_PLATFORM ios)
    elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows" OR (NOT CMAKE_SYSTEM_NAME AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows"))
        set(CURRENT_TARGET_TRIPLET_PLATFORM windows)
    elseif(CMAKE_SYSTEM_NAME STREQUAL "FreeBSD" OR (NOT CMAKE_SYSTEM_NAME AND CMAKE_HOST_SYSTEM_NAME STREQUAL "FreeBSD"))
        set(CURRENT_TARGET_TRIPLET_PLATFORM freebsd)
    endif()
    #### End - Get target triplet platform

    #### set TARGET_TRIPLET, like `x64-windows`、`x64-linux`
    set(${target_triplet} ${CURRENT_TARGET_TRIPLET_ARCH}-${CURRENT_TARGET_TRIPLET_PLATFORM} PARENT_SCOPE)
endfunction(get_target_triplet)

##
# @brief get subdir list from ${curdir}
#
# @param result [required] : the subdir list
# @param curdir [required] : current directory
##
MACRO(get_subdir_list result curdir)
    FILE(GLOB children RELATIVE ${curdir} CONFIGURE_DEPENDS ${curdir}/*)
    SET(dirlist "")
    FOREACH(child ${children})
        IF(IS_DIRECTORY ${curdir}/${child})
            MESSAGE(STATUS "ADD source folder: " ${child})
            LIST(APPEND dirlist ${child})
        ENDIF()
    ENDFOREACH()
    SET(${result} ${dirlist})
ENDMACRO()

## get .h .cpp .hpp .c .cc file list from dir and subdir
function(get_file_list filelist curdir)
    FILE(GLOB_RECURSE files RELATIVE ${curdir} CONFIGURE_DEPENDS
    ${curdir}/*.h
    ${curdir}/*.cpp
    ${curdir}/*.hpp
    ${curdir}/*.c
    ${curdir}/*.cc)
    SET(${filelist} ${files} PARENT_SCOPE)
endfunction()

## get .h .cpp .hpp .c .cc file list from dir and subdir
function(get_full_pash_file_list filelist curdir)
    FILE(GLOB_RECURSE files ${curdir}
    ${curdir}/*.h
    ${curdir}/*.cpp
    ${curdir}/*.hpp
    ${curdir}/*.c
    ${curdir}/*.cc)
    SET(${filelist} ${files} PARENT_SCOPE)
endfunction()

## get dir list from dir and subdir
function(get_dir_list dirlist curdir)
    FILE(GLOB_RECURSE dirs RELATIVE ${curdir} CONFIGURE_DEPENDS ${curdir}/*)
    SET(dirlist "")
    FOREACH(dir ${dirs})
        IF(IS_DIRECTORY ${curdir}/${dir})
            # MESSAGE(STATUS "ADD source folder: " ${dir})
            LIST(APPEND dirlist ${dir})
        ENDIF()
    ENDFOREACH()
    SET(${dirlist} ${dirlist} PARENT_SCOPE)
endfunction()
