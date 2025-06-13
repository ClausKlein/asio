cmake_minimum_required(VERSION 3.30...4.0)

project(asio-examples VERSION 1.34.2.1 LANGUAGES CXX)

if(PROJECT_IS_TOP_LEVEL)
    find_package(asio ${PROJECT_VERSION} REQUIRED HINTS ../../stagedir)
endif()

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    add_compile_options(-fexperimental-library)
    if(APPLE)
        add_link_options(-L$ENV{LLVM_ROOT}/lib/c++)
    endif()
    add_link_options(-lc++experimental)
    add_compile_options(-stdlib=libc++)
    add_link_options(-stdlib=libc++)
    add_executable(timer4 cpp11/tutorial/timer4/timer.cpp)
    target_link_libraries(timer4 PUBLIC asio::asio_header)
endif()

add_executable(async_tcp_client cpp11/timeouts/async_tcp_client.cpp)
target_link_libraries(async_tcp_client PUBLIC asio::asio_header)

add_executable(
    chat_client
    cpp11/chat/chat_client.cpp
    cpp11/chat/chat_message.hpp
)
target_link_libraries(chat_client PUBLIC asio::asio_header)

add_executable(
    chat_server
    cpp11/chat/chat_server.cpp
    cpp11/chat/chat_message.hpp
)
target_link_libraries(chat_server PUBLIC asio::asio_header)
