cmake_minimum_required(VERSION 3.25...3.31)

project(asio_test LANGUAGES CXX)

include(../../cmake/project-is-top-level.cmake OPTIONAL)
include(../../cmake/folders.cmake OPTIONAL)
include(../../cmake/windows-set-path.cmake OPTIONAL)

# ---- Dependencies ----

if(PROJECT_IS_TOP_LEVEL)
  find_package(asio 1.32.0.1 EXACT REQUIRED)
  enable_testing()
endif()

# ---- Tests ----

add_executable(asio_test unit/read_until.cpp)

if(TARGET asio::asio)
  target_link_libraries(asio_test asio::asio)
else()
  target_link_libraries(asio_test asio::asio_header)
endif()

if(NOT PROJECT_IS_TOP_LEVEL)
  if(NOT DEFINED CMAKE_PREFIX_PATH)
    set(CMAKE_PREFIX_PATH ${CMAKE_INSTALL_PREFIX})
  endif()

  # test if the targets are findable from the build directory
  # NOTE: For an INTERFACE library and multi config generators, we may always use
  # the -C Debug config type instead of  $<CONFIG> to prevent problems! CK
  if(CMAKE_BUILD_TYPE STREQUAL Debug)
    add_test(
      NAME find-package-test
      COMMAND ${CMAKE_CTEST_COMMAND} --verbose --output-on-failure -C Debug --build-and-test
              "${CMAKE_SOURCE_DIR}/module/tests" "${CMAKE_CURRENT_BINARY_DIR}/find-package-test" --build-generator
              ${CMAKE_GENERATOR} --build-makeprogram ${CMAKE_MAKE_PROGRAM} --build-options
              "-DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}" "-DCMAKE_CXX_STANDARD=${CMAKE_CXX_STANDARD}"
              "-DCMAKE_BUILD_TYPE=Debug" "-DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}"
    )
  endif()
endif()

# ---- Setup strict Compiler Warnings ----

add_test(NAME asio_test COMMAND asio_test)

# ---- End-of-file commands ----

if(NOT PROJECT_IS_TOP_LEVEL)
  add_folders(Tests)
endif()
