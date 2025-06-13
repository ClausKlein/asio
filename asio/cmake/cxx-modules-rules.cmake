# Use modules?
unset(ASIO_USE_MODULES)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_EXTENSIONS OFF)
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
            add_link_options(-L$ENV{LLVM_ROOT}/lib/c++)
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
