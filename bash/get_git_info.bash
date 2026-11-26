#!/bin/bash
# shellcheck disable=SC2034

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CUR_DIR="$(pwd)"

source "${SCRIPT_DIR}/utils.bash"

{
    echo "--LAMMPS Chemtrain--" > "${git_info_file}"
    git describe --tags --abbrev=0  #Last Git tag
    git rev-parse --abbrev-ref HEAD  #Branch Name
    git log -1 --format=%H  #Last Commit hash
    echo "------------------"
} >> "${git_info_file}"

cd "${SCRIPT_DIR}"/../tensorial

{
    echo "--Tensorial--"
    git log -1 --format=%H
    echo "------------------"
} >> "${git_info_file}"

cd "${SCRIPT_DIR}"/../chemtrain

{
    echo "--Chemtrain--"
    git log -1 --format=%H
    echo "------------------"
} >> "${git_info_file}"

cd "${CUR_DIR}"
