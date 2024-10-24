include(FindPackageHandleStandardArgs)

find_library(SDL2_LIBRARY NAMES SDL2)
find_library(SDL2_Main_LIBRARY NAMES SDL2main)
find_path(SDL2_INCLUDE_DIR NAMES SDL2/SDL.h)

if (SDL2_INCLUDE_DIR)
  file(STRINGS "${SDL2_INCLUDE_DIR}/SDL2/SDL_version.h" version-file
    REGEX "#define[ \t]SDL_(MAJOR|MINOR|PATCHLEVEL).*")
  if (NOT version-file)
    message(AUTHOR_WARNING "SDL2_INCLUDE_DIR found, but SDL_version.h is missing")
  endif()
  list(GET version-file 0 major-line)
  list(GET version-file 1 minor-line)
  list(GET version-file 2 patch-line)
  string(REGEX REPLACE "^#define[ \t]+SDL_MAJOR_VERSION[ \t]+([0-9]+)$" "\\1" SDL2_VERSION_MAJOR ${version-file})
  string(REGEX REPLACE "^#define[ \t]+SDL_MINOR_VERSION[ \t]+([0-9]+)$" "\\1" SDL2_VERSION_MINOR ${version-file})
  string(REGEX REPLACE "^#define[ \t]+SDL_PATCHLEVEL[ \t]+([0-9]+)$" "\\1" SDL2_VERSION_PATCH ${version-file})
  set(SDL2_VERSION ${SDL2_VERSION_MAJOR}.${SDL2_VERSION_MINOR}.${SDL2_VERSION_PATCH} CACHE "SDL2 Version")
endif()

if (SDL2_Main_LIBRARY)
  set(SDL2_Main_FOUND YES)
endif()

find_package_handle_standard_args(SDL2
  REQUIRED_VARS SDL2_LIBRARY SDL2_INCLUDE_DIR
  VERSION_VAR SDL2_VERSION
  HANDLE_COMPONENTS)

if (SDL2_FOUND)
  mark_as_advanced(SDL2_INCLUDE_DIR)
  mark_as_advanced(SDL2_LIBRARY)
  mark_as_advanced(SDL2_VERSION)
endif()

if (SDL2_Main_FOUND)
  mark_as_advanced(SDL2_Main_LIBRARY)
endif()

if (SDL2_FOUND AND NOT TARGET SDL2::SDL2)
  add_library(SDL2::SDL2 IMPORTED)
  set_property(TARGET SDL2::SDL2 PROPERTY IMPORTED_LOCATION ${SDL2_LIBRARY})
  set_property(TARGET SDL2::SDL2 PROPERTY VERSION ${SDL2_VERSION})
  target_include_directories(SDL2::SDL2 INTERFACE ${SDL2_INCLUDE_DIR})
endif()

if (SDL2_Main_FOUND AND NOT TARGET SDL2::Main)
  add_library(SDL2::Main IMPORTED)
  set_property(TARGET SDL2::Main PROPERTY IMPORTED_LOCATION ${SDL2_Main_LIBRARY})
  target_link_libraries(SDL2::Main INTERFACE SDL2::SDL2)
endif()