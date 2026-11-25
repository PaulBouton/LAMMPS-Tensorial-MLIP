#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CUR_DIR="$(pwd)"

source "${SCRIPT_DIR}/utils.bash"

echo "--LAMMPS Chemtrain--" > ${git_info_file}
git describe --tags --abbrev=0 >> ${git_info_file} #Last Git tag
git rev-parse --abbrev-ref HEAD >> ${git_info_file} #Branch Name
git log -1 --format=%H >> ${git_info_file} #Last Commit hash
echo "------------------" >> ${git_info_file}

cd ${SCRIPT_DIR}/../tensorial
echo "--Tensorial--" >> ${git_info_file}
git log -1 --format=%H >> ${git_info_file}
echo "------------------" >> ${git_info_file}

cd ${SCRIPT_DIR}/../chemtrain
echo "--Chemtrain--" >> ${git_info_file}
git log -1 --format=%H >> ${git_info_file}
echo "------------------" >> ${git_info_file}

cd ${CUR_DIR}
