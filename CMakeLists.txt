#Specify the version being used as well as the language
cmake_minimum_required(VERSION 2.8.11)

#Name your project here
project(qcl-tdi)

#set the module directory
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}")

#find the pthreads package
find_package(Threads)

#find the X11 package
find_package(X11)

#ask for the Aerotech A3200 library file
find_library(AEROTECH_LIB NAMES A3200C.lib PATHS lib32)

#ask for the Teledyne API libraries
find_library(TELEDYNE_ACQ_LIB NAMES ipsacq.lib PATHS lib32)
find_library(TELEDYNE_SAPERA_LIB NAMES ipssaperalt.lib PATHS lib32)
find_library(TELEDYNE_FRAMEGRAB_LIB NAMES sbfem.lib PATHS lib32)

#build the executable in the binary directory on MS Visual Studio
if ( MSVC )
	SET( CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG "${OUTPUT_DIRECTORY}")
	SET( CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE "${OUTPUT_DIRECTORY}")
endif ( MSVC )

include_directories(
					"include"
					)

#Assign source files to the appropriate variables
file(GLOB SRC_CPP "*.cpp")
file(GLOB SRC_H "*.h")

#create an executable file
add_executable(qcl-tdi
				${SRC_H}
				${SRC_CPP}
				)

#set the link libraries
target_link_libraries(qcl-tdi
						${AEROTECH_LIB}
						${TELEDYNE_ACQ_LIB}
						${TELEDYNE_SAPERA_LIB}
						${TELEDYNE_FRAMEGRAB_LIB}
						${CMAKE_THREAD_LIBS_INIT}
		  )
