cmake_minimum_required(VERSION 3.30...4.0)

include(cmake/prelude.cmake)

project(
    asio
    VERSION 1.34.2.1
    DESCRIPTION "Asio C++ Library"
    HOMEPAGE_URL "http://think-async.com/Asio/"
    LANGUAGES CXX
)

include(cmake/variables.cmake)

if(PROJECT_IS_TOP_LEVEL)
    include(CheckCXXSymbolExists)
    check_cxx_symbol_exists(snprintf cstdio ASIO_HAS_SNPRINTF)
    check_cxx_symbol_exists(sprintf_s cstdio ASIO_HAS_SECURE_RTL)
endif()

set(CPPdefinitions ASIO_NO_DEPRECATED ASIO_DISABLE_BOOST_CONTEXT_FIBER)
if(ASIO_HAS_SECURE_RTL)
    list(APPEND CPPdefinitions ASIO_HAS_SECURE_RTL)
elseif(ASIO_HAS_SNPRINTF)
    list(APPEND CPPdefinitions ASIO_HAS_SNPRINTF)
endif()

if(MSVC)
    list(APPEND CPPdefinitions -DASIO_INLINE_VARIABLE=inline)
endif()

option(ASIO_SEPARATE_COMPILATION "build asio lib too" ${PROJECT_IS_TOP_LEVEL})
option(ASIO_BUILD_EXAMPLES "build asio examples too" ${PROJECT_IS_TOP_LEVEL})

set(CMAKE_SKIP_TEST_ALL_DEPENDENCY OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_CXX_VISIBILITY_PRESET hidden)
set(CMAKE_VISIBILITY_INLINES_HIDDEN ON)
set(CMAKE_DEBUG_POSTFIX D)

include(cmake/cxx-modules-rules.cmake)

# ---- add dependency libraries ----

find_package(Threads REQUIRED)
find_package(OpenSSL)

# ---- Declare library ----

file(
    GLOB_RECURSE _asio_implementation
    "include/asio/*/*.hpp"
    "include/asio/*.ipp"
)
list(FILTER _asio_implementation EXCLUDE REGEX [=[.*/experimental/.*]=])

# asio interface library
add_library(asio_header INTERFACE)
add_library(asio::asio_header ALIAS asio_header)
target_sources(
    asio_header
    INTERFACE FILE_SET HEADERS BASE_DIRS include FILES ${_asio_implementation}
)
if(OpenSSL_FOUND)
    target_link_libraries(asio_header INTERFACE OpenSSL::SSL OpenSSL::Crypto)
    list(APPEND CPPdefinitions ASIO_HAS_OPENSSL)
endif()

target_compile_definitions(asio_header INTERFACE ${CPPdefinitions})
target_compile_features(asio_header INTERFACE cxx_std_23)
target_link_libraries(asio_header INTERFACE Threads::Threads)

if(ASIO_SEPARATE_COMPILATION)
    set(_libasio_SOURCES src/asio.cpp)

    if(OpenSSL_FOUND)
        list(APPEND _libasio_SOURCES src/asio_ssl.cpp)
    endif()

    set(CMAKE_VERIFY_INTERFACE_HEADER_SETS ${PROJECT_IS_TOP_LEVEL})

    file(GLOB_RECURSE _asio_headers "include/asio/*.hpp")
    list(FILTER _asio_headers EXCLUDE REGEX [=[.*/experimental/.*\.hpp]=])
    list(FILTER _asio_headers EXCLUDE REGEX [=[.*/spawn.*\.hpp]=])

    # FIXME: some header in include/asio/detail fails CMAKE_VERIFY_INTERFACE_HEADER_SETS!
    # NOTE: we need them installed, but we used them install with asio_header INTERFACE! CK
    set(_public_headers include/asio.hpp ${_asio_headers})
    list(FILTER _public_headers EXCLUDE REGEX [=[.*/detail/.*\.hpp]=])
    list(FILTER _public_headers EXCLUDE REGEX [=[.*/impl/.*\.hpp]=])
    list(FILTER _public_headers EXCLUDE REGEX [=[.*/spawn.*\.hpp]=])
    # foreach(header in LISTS ${_public_headers})
    #   message(INFO "${header}")
    # endforeach()

    add_library(asio ${_libasio_SOURCES})
    add_library(asio::asio ALIAS asio)
    target_sources(
        asio
        PUBLIC
            FILE_SET public_headers
            TYPE HEADERS
            BASE_DIRS include
            FILES ${_public_headers}
    )

    target_compile_definitions(
        asio
        PUBLIC ASIO_SEPARATE_COMPILATION ${CPPdefinitions}
    )
    target_link_libraries(asio PUBLIC Threads::Threads)
    target_compile_features(asio PUBLIC cxx_std_23)

    if(ASIO_WARNINGS_AS_ERRORS AND ASIO_DEVELOPER_MODE AND UNIX)
        target_compile_options(asio PUBLIC -Werror)
    endif()

    if(OpenSSL_FOUND)
        target_link_libraries(asio PUBLIC OpenSSL::SSL OpenSSL::Crypto)
    endif()
endif()

if(ASIO_USE_MODULES)
    add_library(asio_module)
    add_library(asio::asio_module ALIAS asio_module)
    target_compile_features(asio_module PUBLIC cxx_std_23)
    target_sources(
        asio_module
        PUBLIC FILE_SET CXX_MODULES FILES module/asio.cppm
    )
    target_link_libraries(asio_module PUBLIC asio_header)
    target_compile_definitions(asio_module PUBLIC ${CPPdefinitions})
endif()

if(ASIO_BUILD_EXAMPLES)
    add_subdirectory(src/examples)
endif()

# ---- Install rules ----

if(NOT CMAKE_SKIP_INSTALL_RULES)
    include(cmake/install-rules.cmake)
    configure_file(asio.pc.cmake asio.pc)
    install(
        FILES ${PROJECT_BINARY_DIR}/asio.pc
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig
    )
    install(
        FILES module/asio.cppm
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/asio/module
    )
endif()

# ---- Developer mode ----

if(NOT ASIO_DEVELOPER_MODE)
    return()
elseif(NOT PROJECT_IS_TOP_LEVEL)
    message(AUTHOR_WARNING "Developer mode is intended for developers of asio")
endif()

include(cmake/dev-mode.cmake)
