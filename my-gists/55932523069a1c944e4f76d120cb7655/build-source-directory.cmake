cmake_minimum_required(VERSION 3.15)

get_filename_component(name ${CMAKE_CURRENT_LIST_DIR} NAME)

project(${name})

set(CMAKE_INCLUDE_CURRENT_DIR ON)

# Get all source files, CONFIGURE_DEPENDS makes sure that if you add
# new files and build, they will be picked up. Tested with Ninja
file(GLOB_RECURSE sources
     RELATIVE ${CMAKE_CURRENT_LIST_DIR}
     CONFIGURE_DEPENDS "*.c" "*.h" "*.cpp" "*.hpp" "*.cxx" "*.hxx")

# Remove CMake build directory files, when you are doing in source directory 
# builds: cmake -GNinja -S . -B build
file(RELATIVE_PATH buildDir ${CMAKE_CURRENT_LIST_DIR} ${CMAKE_BINARY_DIR})
list(FILTER sources EXCLUDE REGEX "${buildDir}/*")

add_executable(${name} ${sources})

# For Debugging
#include(CMakePrintHelpers)
#cmake_print_variables(sources)
