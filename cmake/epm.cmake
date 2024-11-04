##
# @Author: Qiang Wang
# @date: 2022-07-26 17:19:40
# @last_author: Qiang Wang (wangq@yusur.tech)
# @last_edit_time: 2022-07-26 17:19:40
##
##
# @brief: Easy Package Manager
# @Company: YUSUR. Copyright(c) All rights reserved
# @version: v0.1
# @Author: Qiang Wang
# @Date: 2020-06-02 17:10:45
# @LastEditTime: 2020-06-05 18:09:51
# @LastEditors: Qiang Wang
# @Usage:   first, you need to include this file to your project, just like `include (epm.cmake)`
#           then, download what you want, epm_download_package(
#                                               NAME        YUSUR_THIRD_PARTY
#                                               TAG         x64-linux
#                                               URL         git@192.168.2.114:ystech/third_party.git
#                                               SOURCE_DIR  ${CMAKE_CURRENT_SOURCE_DIR}/../library
#                                           )
#           finally, add pacakges or components to your project, use `epm_add_all_packages_to_target` to add all components
#               of all packages, or use `epm_add_packages_to_target` to add some packages, or use `epm_add_componentsto_target` to
#               add some components of package after call `add_executable` or `add_library` in top level CMakeLists.txt.
##

## epm version 0.1
set(EPM_VERSION_MAJOR 0)
set(EPM_VERSION_MINOR 1)

## include `CMakeParseArguments` to use the function `cmake_parse_arguments`
include(CMakeParseArguments)

## EPM_SOURCE_DIR : the download directory
set(EPM_SOURCE_DIR "")
## All packages added to epm
set(EPM_PACKAGES)

##
# @brief download package from gitlab/github
#
# @param NAME [optional] : the name of the epm package
# @param TAG [required] : the branch/tag name of the git repository
# @param URL [required] : the url of the git repository
# @param SOURCE_DIR [optional] : destination directory to save downloaded files，
#                           if not given, use `${CMAKE_CURRENT_SOURCE_DIR}/library/${EPM_ARGS_TAG}` as default
##
function(epm_download_package)
    message(STATUS "===> run into epm_download_package()")
    set(one_value_args
        NAME
        TAG
        URL
        SOURCE_DIR
    )

    set(multi_value_args
        OPTIONS
    )

    set(EPM_ARGS_TAG_LOWER)

    ## parse all arguments
    cmake_parse_arguments(EPM_ARGS "" "${one_value_args}" "${multi_value_args}" "${ARGN}")

    ## checkout all arguments
    if (DEFINED EPM_ARGS_NAME)
        message(STATUS "EPM_ARGS_NAME : ${EPM_ARGS_NAME}")
    endif()

    if(DEFINED EPM_ARGS_TAG)
        message(STATUS "EPM_ARGS_TAG : ${EPM_ARGS_TAG}")
        string(TOLOWER ${EPM_ARGS_TAG} EPM_ARGS_TAG_LOWER)
    else()
        message(FATAL_ERROR "EPM_ARGS_TAG is required but not gived.")
        return()
    endif(DEFINED EPM_ARGS_TAG)

    if(DEFINED EPM_ARGS_URL)
        message(STATUS "EPM_ARGS_URL : ${EPM_ARGS_URL}")
    else()
        message(FATAL_ERROR "EPM_ARGS_URL is required but not gived.")
        return()
    endif(DEFINED EPM_ARGS_URL)

    if(DEFINED EPM_ARGS_SOURCE_DIR)
        message(STATUS "EPM_ARGS_SOURCE_DIR : ${EPM_ARGS_SOURCE_DIR}")
    else()
        set(EPM_ARGS_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/library/${EPM_ARGS_TAG_LOWER})
    endif(DEFINED EPM_ARGS_SOURCE_DIR)

    set(dst_dir ${EPM_ARGS_SOURCE_DIR}/${EPM_ARGS_TAG_LOWER})
    # set the global variant
    set(EPM_SOURCE_DIR ${dst_dir} PARENT_SCOPE)

    if(EXISTS ${dst_dir})
        message(STATUS "${dst_dir} exists, get the newest version.")
        execute_process(COMMAND git pull --rebase origin ${EPM_ARGS_TAG_LOWER}
                        WORKING_DIRECTORY ${dst_dir})
    else()
        execute_process(COMMAND git clone -b ${EPM_ARGS_TAG_LOWER} ${EPM_ARGS_URL} ${dst_dir})
    endif()
    message(STATUS "<=== run out epm_download_package()")
endfunction(epm_download_package)

##
# @brief get subdirectory list
#
# @param result [out] : subdirectory list
# @param curdir [in] : current directory
##
macro(get_sub_dir_list result curdir)
    file(GLOB children RELATIVE ${curdir} ${curdir}/*)
    set(dirlist "")
    foreach(child ${children})
        if(IS_DIRECTORY ${curdir}/${child})
            LIST(APPEND dirlist ${child})
        endif()
    endforeach()
    set(${result} ${dirlist})
endmacro()

##
# @brief add all packages to the target
#
# @param target_name : the name of target
##
function(epm_add_all_packages_to_target target_name)
    message(STATUS "===> run into epm_add_all_packages_to_target()")
    get_sub_dir_list(dirlist ${EPM_SOURCE_DIR})
    message(STATUS "EPM_SOURCE_DIR : ${EPM_SOURCE_DIR}")

    ## traverse the child directoris of ${EPM_SOURCE_DIR}
    foreach(dir ${dirlist})
        # TODO: use regex to match string
        if((NOT (${dir} MATCHES .build))
            AND (NOT (${dir} MATCHES .vscode))
            AND (NOT (${dir} MATCHES .git)) )
            list(APPEND EPM_PACKAGES ${dir})
            message(STATUS "include ${EPM_SOURCE_DIR}/${dir}/${dir}.cmake")
            include(${EPM_SOURCE_DIR}/${dir}/${dir}.cmake)
            add_all_components_to_target(${target_name} ${dir})
        endif()
    endforeach()
    message(STATUS "<=== run out  epm_add_all_packages()")
endfunction(epm_add_all_packages_to_target)

##
# @brief add all components of packages to target
#
# @param target_name : the name of target
# @param pkgs : package name list
##
function(epm_add_packages_to_target target_name)
    message(STATUS "===> run into epm_add_packages_to_target()")
    ## traverse the pkg_name in list
    foreach(pkg_name ${ARGN})
        include(${EPM_SOURCE_DIR}/${pkg_name}/${pkg_name}.cmake)
        add_all_components_to_target(${target_name} ${pkg_name})
    endforeach()
    message(STATUS "<=== run out  epm_add_packages_to_target()")
endfunction(epm_add_packages_to_target)

##
# @brief add some components of package
#
# @param pkg_name : package name
# @param comps : component name list
##
function(epm_add_components_to_target target_name pkg_name)
    message(STATUS "===> run into epm_add_components_to_target()")
    include(${EPM_SOURCE_DIR}/${pkg_name}/${pkg_name}.cmake)
    add_components_to_target(${target_name} ${pkg_name} ${ARGN})
    message(STATUS "<=== run out  epm_add_components_to_target()")
endfunction(epm_add_components_to_target)
