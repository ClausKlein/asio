include(cmake/folders.cmake)

option(ASIO_BUILD_TESTING "Use ctest" ON)
if(ASIO_BUILD_TESTING)
  enable_testing()
  add_subdirectory(src/tests)
endif()

option(ASIO_BUILD_MCSS_DOCS "Build documentation using Doxygen and m.css" OFF)
if(ASIO_BUILD_MCSS_DOCS)
  include(cmake/docs.cmake)
endif()

option(ASIO_ENABLE_COVERAGE "Enable coverage support separate from CTest's" OFF)
if(ASIO_ENABLE_COVERAGE)
  include(cmake/coverage.cmake)
endif()

include(cmake/lint-targets.cmake)
include(cmake/spell-targets.cmake)

add_folders(Project)
