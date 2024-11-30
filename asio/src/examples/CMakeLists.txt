cmake_minimum_required(VERSION 3.25...3.31)

project(asio_examples LANGUAGES CXX)

if(PROJECT_IS_TOP_LEVEL)
  # Find the Asio package containing the function to build the module
  find_package(asio 1.32.0.1 EXACT REQUIRED HINT ../stagedir/lib)
  enable_testing()

  # Use modules?
  unset(USE_MODULES)
  set(CMAKE_CXX_STANDARD 23)
  set(CMAKE_CXX_EXTENSIONS OFF)
  set(CMAKE_CXX_STANDARD_REQUIRED ON)
  if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.28.4 AND CMAKE_GENERATOR STREQUAL "Ninja")
    if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang" AND CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 17.0)
      set(USE_MODULES TRUE)
      # see https://releases.llvm.org/15.0.0/projects/libcxx/docs/ReleaseNotes.html
      # Always use libc++
      add_compile_options(-fexperimental-library)
      add_link_options(-lc++experimental)
      add_compile_options(-stdlib=libc++)
      add_link_options(-stdlib=libc++)
    elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" AND CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 15.0)
      set(USE_MODULES TRUE)
    endif()
    message(STATUS "CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES=${CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES}")
  endif()
  if(USE_MODULES)
    # Build the asio module
    add_asio_module(asio_module)
  endif()

endif()

# set(ALL_EXAMPLES cpp20/operations/callback_wrapper.cpp)
# set(ALL_EXAMPLES module/tests/main.cpp)
set(ALL_EXAMPLES main)

message(STATUS "Examples to be built: ${ALL_EXAMPLES}")

foreach(example ${ALL_EXAMPLES})
  add_executable(${example})
  target_sources(${example} PRIVATE ../../module/tests/${example}.cpp)
  if(USE_MODULES)
    target_link_libraries(${example} asio_module)
    target_compile_definitions(${example} PUBLIC USE_MODULES)
  else()
    target_link_libraries(${example} asio::asio_header)
  endif()
  add_test(NAME ${example} COMMAND echo Test | ${example})
endforeach()
