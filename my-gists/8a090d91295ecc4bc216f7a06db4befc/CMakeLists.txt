cmake_minimum_required(VERSION 3.14)
project(find-packages)
list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)

find_package(Sphinx MODULE REQUIRED)