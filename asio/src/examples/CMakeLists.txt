cmake_minimum_required(VERSION 3.25...3.31)

project(asio_examples LANGUAGES CXX)

if(PROJECT_IS_TOP_LEVEL)
  find_package(asio 1.32.0.1 EXACT REQUIRED)
  enable_testing()
endif()

set(ALL_EXAMPLES callback_wrapper)

message(STATUS "Examples to be built: ${ALL_EXAMPLES}")

foreach(example ${ALL_EXAMPLES})
  add_executable(${example})
  target_sources(${example} PRIVATE cpp20/operations/${example}.cpp)
  target_link_libraries(${example} asio::asio_header)
  add_test(NAME ${example} COMMAND echo Test | ${example})
endforeach()
