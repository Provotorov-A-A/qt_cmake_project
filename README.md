# qt_cmake_project

# Description
Template for C++ project that uses CMake and Qt.
Project contains bash script to ease project building process.

# Steps to build project
0. Create your project directory. 

   `mkdir -p ~/projects/my_qt_project`
   
   `cd ~/projects/my_qt_project`
1. Clone project from repository.

   `clone https://github.com/Provotorov-A-A/qt_cmake_project.git`
2. Rename project name in ./CMakeLists.txt (line with *project* command). 

   That line will be:
   `project(my_qt_project LANGUAGES CXX)`
3. Run help script with command *config*

   `./scripts/make.sh config`
4. Run help script with command *build*

   `./scripts/make.sh build`
5. Run help script with command *run*

   `./scripts/make.sh run`
6. You can also use help-script to to execute *clean* and *install* targets. Use help:

   `./scripts/make.sh --help`
