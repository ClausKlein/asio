cmake_minimum_required(VERSION 3.30...4.0)

project(asio_moddule_examples LANGUAGES CXX)

if(PROJECT_IS_TOP_LEVEL)
    # Find the Asio package containing the function to build the module
    find_package(asio 1.34.2.1 EXACT REQUIRED HINT ../../stagedir/lib)
    enable_testing()

    include(../../cmake/cxx-modules-rules.cmake)

    if(ASIO_USE_MODULES)
        # Build the asio module
        add_asio_module(asio_module)
    endif()
endif()

# list(APPEND ALL_EXAMPLES module/tests/main.cpp)
set(ALL_EXAMPLES main)

message(STATUS "Module tests to be built: ${ALL_EXAMPLES}")

foreach(example ${ALL_EXAMPLES})
    add_executable(${example})
    target_sources(${example} PRIVATE ${example}.cpp)
    if(TARGET asio_module)
        target_link_libraries(${example} asio_module)
        target_compile_definitions(${example} PUBLIC USE_MODULES)
    else()
        target_link_libraries(${example} asio::asio_header)
    endif()
    add_test(NAME module_test_${example} COMMAND echo Test | ${example})
endforeach()
