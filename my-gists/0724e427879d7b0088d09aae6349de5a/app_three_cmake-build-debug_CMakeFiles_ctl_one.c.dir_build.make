# CMAKE generated file: DO NOT EDIT!
# Generated by "MinGW Makefiles" Generator, CMake Version 3.16

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:


#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:


# Remove some rules from gmake that .SUFFIXES does not remove.
SUFFIXES =

.SUFFIXES: .hpux_make_needs_suffix_list


# Suppress display of executed commands.
$(VERBOSE).SILENT:


# A target that is always out of date.
cmake_force:

.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

SHELL = cmd.exe

# The CMake executable.
CMAKE_COMMAND = "D:\Tools\Clion\CLion 2020.1.2\bin\cmake\win\bin\cmake.exe"

# The command to remove a file.
RM = "D:\Tools\Clion\CLion 2020.1.2\bin\cmake\win\bin\cmake.exe" -E remove -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = D:\source\app_three

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = D:\source\app_three\cmake-build-debug

# Include any dependencies generated for this target.
include CMakeFiles/ctl_one.c.dir/depend.make

# Include the progress variables for this target.
include CMakeFiles/ctl_one.c.dir/progress.make

# Include the compile flags for this target's objects.
include CMakeFiles/ctl_one.c.dir/flags.make

CMakeFiles/ctl_one.c.dir/ctl_one.c.obj: CMakeFiles/ctl_one.c.dir/flags.make
CMakeFiles/ctl_one.c.dir/ctl_one.c.obj: CMakeFiles/ctl_one.c.dir/includes_C.rsp
CMakeFiles/ctl_one.c.dir/ctl_one.c.obj: ../ctl_one.c
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=D:\source\app_three\cmake-build-debug\CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building C object CMakeFiles/ctl_one.c.dir/ctl_one.c.obj"
	C:\stuff\libs\C\mingw64\bin\gcc.exe $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -o CMakeFiles\ctl_one.c.dir\ctl_one.c.obj   -c D:\source\app_three\ctl_one.c

CMakeFiles/ctl_one.c.dir/ctl_one.c.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing C source to CMakeFiles/ctl_one.c.dir/ctl_one.c.i"
	C:\stuff\libs\C\mingw64\bin\gcc.exe $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -E D:\source\app_three\ctl_one.c > CMakeFiles\ctl_one.c.dir\ctl_one.c.i

CMakeFiles/ctl_one.c.dir/ctl_one.c.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling C source to assembly CMakeFiles/ctl_one.c.dir/ctl_one.c.s"
	C:\stuff\libs\C\mingw64\bin\gcc.exe $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -S D:\source\app_three\ctl_one.c -o CMakeFiles\ctl_one.c.dir\ctl_one.c.s

# Object files for target ctl_one.c
ctl_one_c_OBJECTS = \
"CMakeFiles/ctl_one.c.dir/ctl_one.c.obj"

# External object files for target ctl_one.c
ctl_one_c_EXTERNAL_OBJECTS =

ctl_one.c.exe: CMakeFiles/ctl_one.c.dir/ctl_one.c.obj
ctl_one.c.exe: CMakeFiles/ctl_one.c.dir/build.make
ctl_one.c.exe: CMakeFiles/ctl_one.c.dir/linklibs.rsp
ctl_one.c.exe: CMakeFiles/ctl_one.c.dir/objects1.rsp
ctl_one.c.exe: CMakeFiles/ctl_one.c.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=D:\source\app_three\cmake-build-debug\CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking C executable ctl_one.c.exe"
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles\ctl_one.c.dir\link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
CMakeFiles/ctl_one.c.dir/build: ctl_one.c.exe

.PHONY : CMakeFiles/ctl_one.c.dir/build

CMakeFiles/ctl_one.c.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles\ctl_one.c.dir\cmake_clean.cmake
.PHONY : CMakeFiles/ctl_one.c.dir/clean

CMakeFiles/ctl_one.c.dir/depend:
	$(CMAKE_COMMAND) -E cmake_depends "MinGW Makefiles" D:\source\app_three D:\source\app_three D:\source\app_three\cmake-build-debug D:\source\app_three\cmake-build-debug D:\source\app_three\cmake-build-debug\CMakeFiles\ctl_one.c.dir\DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/ctl_one.c.dir/depend

