#!/usr/bin/bash

###################################################
PLATFORM="unknown"
PATH_DELIM='/'
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        PLATFORM="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
        PLATFORM="macosx"
elif [[ "$OSTYPE" == "cygwin" ]]; then
        PLATFORM="cygwin"
        PATH_DELIM='/'
elif [[ "$OSTYPE" == "msys" ]]; then
        PLATFORM="msys"
        PATH_DELIM='/'
elif [[ "$OSTYPE" == "win32" ]]; then
        PLATFORM="win" # I'm not sure this can happen.
elif [[ "$OSTYPE" == "freebsd"* ]]; then
        PLATFORM="freebsd"
else
        PLATFORM="unknown"
fi

echo "### Platform recognized: $PLATFORM"

###################################################
# SCRIPT CONSTANTS

SCRIPT_DIR=$(dirname $(realpath "$0"))
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
DEFAULT_TARGET_NAME=$(basename $ROOT_DIR)
DEFAULT_BUILD_DIR="${ROOT_DIR}${PATH_DELIM}BUILD"
DEFAULT_INSTALL_DIR="${ROOT_DIR}${PATH_DELIM}INSTALL"

DEFAULT_CMAKE_GENERATOR="Unix Makefiles"
DEFAULT_PROJECT_CONFIGURATION=Debug
DEFAULT_JOBS=-j4

PREBUILD_FILE_RELATIVE="scripts${PATH_DELIM}set_env.sh"
PREBUILD_FILE=${ROOT_DIR}${PATH_DELIM}${PREBUILD_FILE_RELATIVE}


###################################################
PROJECT_CONFIGURATION=$DEFAULT_PROJECT_CONFIGURATION
arg_command=$1

###################################################
# Help string
HELP="make.sh: make.sh [command] [options] 
  Wrapper for cmake used to ease basic operations (config, build, etc) over simple CMake project (one executable target). 
  Root directory name must be the same as CMake project name in CMakeFile.txt.
  Build directory = ./BUILD.
  Install directory =  ./INSTALL.
  Prebuild file shell script may be sourced before any operations will be done. Default file to be searched: ./$PREBUILD_FILE_RELATIVE.
  Commands: 
		make.sh [-help | --help]	- print help
		make.sh config [cmake_gen] 	- do cmake config step with a PWD as CMake source directory. Default generator is ${DEFAULT_CMAKE_GENERATOR}
		make.sh build				- build target
		make.sh run					- try to run file with a same name as PWD dirname in build directory
		make.sh install 			- install target
		make.sh clean 				- remove build and install directory"

###################################################
# PRINT HELP
if [ -z "$arg_command" ] || [ "$arg_command" == "-h" ] || [ "$arg_command" == "--help" ]; then
    echo "${HELP}"
    exit 0
fi

###################################################
# CMAKE 
if [ -z "$CMAKE" ] ; then
	CMAKE=cmake
	echo "### CMAKE variable not specified. Default value ${CMAKE} will be used."
fi

###################################################
# Source prebuild file before start if it exists
if [ -e "$PREBUILD_FILE" ]; then
	echo "### Prebuild file ${PREBUILD_FILE} was found. Source it."
	source "$PREBUILD_FILE"
else
	echo "### Prebuild file ${PREBUILD_FILE} was not found. Skip it."
fi

# ###################################################
# # Insert bin path to PATH if it is not there yet
# if [[ ":$PATH:" != *":${CMAKE_DIR}:"* ]]; then
	# echo "... Add ${CMAKE_DIR} to PATH"
	# export PATH=${CMAKE_DIR}:${PATH}
# fi

###################################################
# CLEAN
if [[ "$arg_command" =~ [Cc][Ll][Ee][Aa][Nn] ]] ; then
	build_dir=${DEFAULT_BUILD_DIR}
	install_dir=${DEFAULT_INSTALL_DIR}
	echo "### Clean. Remove directories: \"${build_dir}\"; \"${install_dir}\""
	[[ -d "${build_dir}" ]] && rm -rf  "${build_dir}"
	[[ -d "${install_dir}" ]] && rm -rf  "${install_dir}"
	exit
fi

###################################################
# CONFIG
if [[ "$arg_command" =~ [Cc][Oo][Nn][Ff][Ii][Gg] ]]	; then
	root_dir=${ROOT_DIR}
	build_dir=${DEFAULT_BUILD_DIR}
	generator=$2
	if [ ! -d "$root_dir" ]; then
		echo "Error! Root directory $root_dir doesn't exist."
		exit
	fi
	if [ -z "${generator}" ]; then
	    generator="${DEFAULT_CMAKE_GENERATOR}"
	    echo "### Generator was not passed. Default generator ${generator} will be used"
	fi
	echo "### Configuring. Generator: ${generator}    Source dir: ${root_dir}   Build dir: ${build_dir}"
	
	# Cmake configuration step invocation
	$CMAKE -G "${generator}"   \
	-S "${root_dir}" \
	-B "${build_dir}"
	exit
fi

###################################################
# BUILD
if [[ "$arg_command" =~ [Bb][Uu][Ii][Ll][Dd] ]]	; then
	jobs_option=$DEFAULT_JOBS
	target_option=$DEFAULT_TARGET_NAME
	project_configuration=${PROJECT_CONFIGURATION}
	build_dir=${DEFAULT_BUILD_DIR}
	
	if [ ! -f "${build_dir}${PATH_DELIM}CMakeCache.txt" ]; then
		echo "### Need CMake config step before build. Stop building."
		exit
	fi
	echo "### Building. Build dir: ${build_dir}"
	
	$CMAKE --build "$build_dir" --verbose ${jobs_option} --target ${target_option} --config ${project_configuration}
	exit
fi

###################################################
# INSTALL
if [[ "$arg_command" =~ [Ii][Nn][Ss][Tt][Aa][Ll][Ll] ]]	; then
	project_configuration=${PROJECT_CONFIGURATION}
	bin_dir=${DEFAULT_BUILD_DIR}
	install_dir=${DEFAULT_INSTALL_DIR}
	echo "### Installing. Install dir: \"${install_dir}\"    Prefix dir: \"${bin_dir}\"."
	$CMAKE --install "${bin_dir}" --prefix ${install_dir} --verbose --config ${project_configuration}
	exit
fi

###################################################
# Run 
if [[ "$arg_command" =~ [Rr][Uu][Nn] ]]; then
	install_dir=${DEFAULT_INSTALL_DIR}
	build_dir=${DEFAULT_BUILD_DIR}
	postfix=""
	# Let's know what environment we running in to get valid executable target. 
	# Not Linux enought for us if we not using Mac (Darwin) for sure.
	# Add .exe postdix to target if we in MinGW or CYGWIN.
# 	if [ ! "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
# 		postfix='.exe'
# 	fi
	
	if [ $PLATFORM == "msys" ]; then
        postfix='.exe'
    fi
	
	intsalled_target=${install_dir}${PATH_DELIM}bin${PATH_DELIM}$DEFAULT_TARGET_NAME$postfix
	build_target=${build_dir}${PATH_DELIM}$DEFAULT_TARGET_NAME$postfix
	
	# Try to run target in default install dir. If it's not found try to run target in default build dir.
	if [ -z "$intsalled_target" ] || [ ! -f "$intsalled_target" ]; then
		if [ -z "$build_target" ] || [ ! -f "$build_target" ]; then
			echo "### Error. Executable not found."
			exit
		else
			echo "### Run. Executable: \"$build_target\""
			${build_target}
			exit
		fi
	else
		echo "### Run. Executable: \"$intsalled_target\""
		${intsalled_target}
		exit
	fi
fi

###################################################
# UNKNOWN COMMAND
echo Unknown command \'"$arg_command"\'
echo "Type <script> --help for help"
