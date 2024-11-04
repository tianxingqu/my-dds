cmake_minimum_required(VERSION 3.20)

project(MDDS)

include(cmake/common.cmake)

include(options.txt)

set(CMAKE_CXX_STANDARD 20)

set(GIT_BRANCH "")
if(WIN32)
    set(GIT_BRANCH "windows")
    message("Windows system")
elseif(APPLE)
    set(GIT_BRANCH "mac")
    message("Apple system")
elseif(UNIX)
    set(GIT_BRANCH "x64-linux")
    message("Unix-like system")
endif()

include (cmake/epm.cmake)
include (cmake/Utilities.cmake)
include (cmake/common.cmake)


epm_download_package(
    NAME        YUSUR_THIRD_PARTY
    TAG         ${GIT_BRANCH}
    URL         https://gitee.com/tianxing_qu/library.git
    SOURCE_DIR  ${CMAKE_CURRENT_SOURCE_DIR}/../librarys
)


set(SRC_SUBDIRS "")
get_subdirectories(${CMAKE_SOURCE_DIR}/src SRC_SUBDIRS)

message(STATUS "SRC_SUBDIRS: ${SRC_SUBDIRS}")

if(UNIT_TEST_ENABLE)
    # 排除掉 main 目录
    list(FILTER SRC_SUBDIRS EXCLUDE REGEX "main")
else()
    # 排除掉 gtest 目录
    list(FILTER SRC_SUBDIRS EXCLUDE REGEX "gtest")
endif()

set(SRC_SOURCES "")
set(SRC_HEADERS "")

foreach(subdir IN LISTS SRC_SUBDIRS)
    get_source_files(${CMAKE_SOURCE_DIR}/src/${subdir} SRC_SUB_SOURCES)
    get_header_files(${CMAKE_SOURCE_DIR}/src/${subdir} SRC_SUB_HEADERS)
    list(APPEND SRC_SOURCES ${SRC_SUB_SOURCES})
    list(APPEND SRC_HEADERS ${SRC_SUB_HEADERS})
endforeach()

message(STATUS "SRC_SOURCES: ${SRC_SOURCES}")
message(STATUS "SRC_HEADERS: ${SRC_HEADERS}")
add_executable(${PROJECT_NAME} ${SRC_SOURCES})

if(UNIT_TEST_ENABLE)
    epm_add_packages_to_target(${PROJECT_NAME}  gtest)
else()
    # epm_add_packages_to_target(${PROJECT_NAME}  )
endif()
