# if(PROJECT_IS_TOP_LEVEL)
# NO!   set(CMAKE_INSTALL_INCLUDEDIR "include/asio-${PROJECT_VERSION}" CACHE PATH "")
# endif()

# Project is configured with no languages, so tell GNUInstallDirs the lib dir
set(CMAKE_INSTALL_LIBDIR lib CACHE PATH "")

include(cmake/AddUninstallTarget.cmake)

include(CMakePackageConfigHelpers)
include(GNUInstallDirs)

# Print Installing but not Up-to-date messages.
set(CMAKE_INSTALL_MESSAGE LAZY)

# find_package(<package) call for consumers to find this project
set(_package asio)

#NO! install(DIRECTORY include/ DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}" COMPONENT asio_Development)

if(TARGET asio_header)
  install(TARGETS asio_header EXPORT asioTargets FILE_SET HEADERS)
endif()
if(TARGET asio)
  install(TARGETS asio EXPORT asioTargets FILE_SET public_headers)
endif()

write_basic_package_version_file("${_package}ConfigVersion.cmake" COMPATIBILITY SameMajorVersion ARCH_INDEPENDENT)

# Allow package maintainers to freely override the path for the configs
set(ASIO_INSTALL_CMAKEDIR "${CMAKE_INSTALL_LIBDIR}/cmake/${_package}"
    CACHE PATH "CMake package config location relative to the install prefix"
)
mark_as_advanced(ASIO_INSTALL_CMAKEDIR)

configure_file(cmake/install-config.cmake install-config.cmake @ONLY)
install(FILES ${PROJECT_BINARY_DIR}/install-config.cmake DESTINATION "${ASIO_INSTALL_CMAKEDIR}"
        RENAME "${_package}Config.cmake" COMPONENT asio_Development
)

install(FILES "${PROJECT_BINARY_DIR}/${_package}ConfigVersion.cmake" DESTINATION "${ASIO_INSTALL_CMAKEDIR}"
        COMPONENT asio_Development
)

install(EXPORT asioTargets NAMESPACE asio:: DESTINATION "${ASIO_INSTALL_CMAKEDIR}" COMPONENT asio_Development)

if(PROJECT_IS_TOP_LEVEL)
  set(CPACK_GENERATOR TGZ)
  include(CPack)
endif()
