#!/usr/bin/bash

###################################################
# SCRIPT CONSTANTS

ROOT_DIR="${PWD}"
DEFAULT_TARGET_NAME=$(basename $ROOT_DIR)
DEFAULT_BUILD_DIR="${ROOT_DIR}/BUILD"
DEFAULT_INSTALL_DIR="${ROOT_DIR}/INSTALL"

DEFAULT_PROJECT_CONFIGURATION=Debug
DEFAULT_JOBS=-j4

PREBUILD_FILE=${ROOT_DIR}/scripts/set_env.sh

###################################################
PROJECT_CONFIGURATION=$DEFAULT_PROJECT_CONFIGURATION
arg_command=$1

###################################################
# Help string
HELP="Build cmake project with MinGW Makefiles generator. Build directory = PWD/BUILD. Project name is a same as PWD dirname. Usage:
<script> [-help | --help]	- print help
<script> clean - remove build directory
<script> config - do cmake config step with a PWD as CMake source directory
<script> build <build_dir> - build target \'target\' to build directory \'build_dir\'. If no \'build_dir\' will be specified default path will be used'
<script> install - install to default intsall directory
<script> run - try to run file with a same name as PWD dirname in build directory."

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
# Source prebuild file before start if it is exists
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
	
	if [ ! -d "$root_dir" ]; then
		echo "Error! Root directory $root_dir doesn't exist."
		exit
	fi

	echo "### Configuring. Source dir: ${root_dir}   Build dir: ${build_dir}"
	
	# Cmake configuration step invocation
	$CMAKE -G "MinGW Makefiles"   \
	-j1 \
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
	build_dir=$2
	
	if [ -z $build_dir ]; then
		build_dir=${DEFAULT_BUILD_DIR}
	fi
	echo "### Building. Build dir: ${build_dir}"
	
#	mkdir -p ${build_dir}
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
	if [ ! "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
		postfix='.exe'
	fi
	
	intsalled_target=${install_dir}/bin/$DEFAULT_TARGET_NAME$postfix
	build_target=${build_dir}/$DEFAULT_TARGET_NAME$postfix
	
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

#read -N 1
