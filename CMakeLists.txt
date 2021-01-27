cmake_minimum_required(VERSION 3.5)

project(qt_cmake_project LANGUAGES CXX)

# Searching for file with local settings
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/CMakeLocal.txt")
	message("File './CMakeLocal.txt' was found. Include './CMakeLocal.txt'.")
	include ("./CMakeLocal.txt")
else()
	message("File './CMakeLocal.txt' not found.")
endif()

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt5 COMPONENTS Widgets REQUIRED)
#find_package(jinja2cpp REQUIRED)

add_executable(${PROJECT_NAME}
	sources/main.cpp
	sources/mainwindow.h
	sources/mainwindow.cpp
)

target_include_directories(${PROJECT_NAME} 
PRIVATE 
	sources
	sources/sta_report_parser
)

target_link_libraries(${PROJECT_NAME} 
PRIVATE 
	Qt5::Widgets 
	#jinja2cpp
)

install (TARGETS ${PROJECT_NAME}
RUNTIME
)
