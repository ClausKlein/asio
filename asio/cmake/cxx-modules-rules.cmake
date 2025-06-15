# Use modules?
unset(ASIO_USE_MODULES)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_EXTENSIONS ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(CMAKE_GENERATOR STREQUAL "Ninja")
    if(
        CMAKE_CXX_COMPILER_ID STREQUAL "Clang"
        AND CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 20.0
    )
        set(ASIO_USE_MODULES TRUE)
        # see https://releases.llvm.org/20.0.0/projects/libcxx/docs/ReleaseNotes.html
        # Always use libc++
        if(APPLE)
            execute_process(
                OUTPUT_VARIABLE LLVM_PREFIX
                COMMAND brew --prefix llvm@20
                COMMAND_ECHO STDOUT
            )
            string(STRIP ${LLVM_PREFIX} LLVM_PREFIX)

            # /usr/local/opt/llvm/share/libc++/v1/std.cppm
            # or /usr/lib/llvm-20/share/libc++/v1/std.cppm
            set(LLVM_LIBC_SOURCE ${LLVM_PREFIX}/share/libc++/v1 CACHE PATH "")
            file(REAL_PATH ${LLVM_PREFIX} LLVM_ROOT)
            set(LLVM_ROOT ${LLVM_ROOT} CACHE PATH "")
            message(STATUS "LLVM_ROOT=${LLVM_ROOT}")

            add_link_options(-L${LLVM_ROOT}/lib/c++)
        endif()
        add_compile_options(-fexperimental-library)
        add_link_options(-lc++experimental)
        add_compile_options(-stdlib=libc++)
        add_link_options(-stdlib=libc++)
    elseif(
        CMAKE_CXX_COMPILER_ID STREQUAL "GNU"
        AND CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 15.0
    )
        set(ASIO_USE_MODULES TRUE)
    elseif(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
        set(ASIO_USE_MODULES TRUE)
    endif()
endif()

message(
    STATUS
    "CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES=${CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES}"
)
