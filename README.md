# qt_cmake_project

## Description
Template for C++ project that uses CMake and Qt.
Project contains bash script to ease project building process.

## Steps to build project
0. Create your project directory. 

   `mkdir -p ~/projects/my_qt_project`
   
   `cd ~/projects/my_qt_project`
1. Clone project from repository.

   `git clone https://github.com/Provotorov-A-A/qt_cmake_project.git .`
2. Rename project name in ./CMakeLists.txt (line with *project* command). 

   That line will be:
   `project(my_qt_project LANGUAGES CXX)`
3. Run help script with command *config* to confige your CMake project.

   `./scripts/make.sh config`
4. Run help script with command *build*

   `./scripts/make.sh build`
5. Run help script with command *run*

   `./scripts/make.sh run`
## Notes
1. You can also use help script to to execute *clean* and *install* targets. Use help:

   `./scripts/make.sh --help`
2. You should have cmake program already installed in your system. You can add or change default environment variables (add cmake path for example) in *./scripts/set_env.sh* file that will be executed before any command with ./scripts/make.sh help file. Also You can add or change default CMake variables by adding it to *./CMakeLocal.txt* file that will be included in CMakeLists.txt file.
