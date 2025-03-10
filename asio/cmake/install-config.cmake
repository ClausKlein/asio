include(CMakeFindDependencyMacro)
find_dependency(Threads)
find_dependency(OpenSSL)

function(add_asio_module NAME)
    set(ASIO_ROOT @CMAKE_INSTALL_PREFIX@)
    message(STATUS "ASIO_ROOT is: ${ASIO_ROOT}")

    add_library(${NAME})
    target_include_directories(${NAME} PRIVATE ${ASIO_ROOT}/include)
    target_compile_features(${NAME} PUBLIC cxx_std_23)

    set(CPPdefinitions "@CPPdefinitions@")
    if(CPPdefinitions)
        target_compile_definitions(${NAME} PUBLIC ${CPPdefinitions})
    endif()

    # cmake-format: off
    target_sources(
        ${NAME}
        PUBLIC
            FILE_SET modules_public
            TYPE CXX_MODULES
            BASE_DIRS ${ASIO_ROOT}
            FILES ${ASIO_ROOT}/lib/cmake/asio/module/asio.cppm
    )
    # cmake-format: on
    target_link_libraries(${NAME} PUBLIC OpenSSL::SSL OpenSSL::Crypto)
endfunction()

include("${CMAKE_CURRENT_LIST_DIR}/asioTargets.cmake")
