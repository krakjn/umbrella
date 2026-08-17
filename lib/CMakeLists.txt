cmake_minimum_required(VERSION 3.16)

execute_process(
  COMMAND bump print --only-base
  WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
  OUTPUT_VARIABLE UMBRELLA_LIB_VERSION
  OUTPUT_STRIP_TRAILING_WHITESPACE
)
if(NOT UMBRELLA_LIB_VERSION)
  set(UMBRELLA_LIB_VERSION "0.1.0")
endif()

project(umbrella VERSION ${UMBRELLA_LIB_VERSION} LANGUAGES C)

add_library(umbrella SHARED src/umbrella.c)
target_include_directories(umbrella
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
  PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/../api/gen
)
set_target_properties(umbrella PROPERTIES
  VERSION ${PROJECT_VERSION}
  SOVERSION 0
  PUBLIC_HEADER include/umbrella.h
  C_STANDARD 99
  C_STANDARD_REQUIRED ON
)

install(TARGETS umbrella
  LIBRARY DESTINATION lib
  PUBLIC_HEADER DESTINATION include/umbrella
)
