#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CUR_DIR="$(pwd)"

source "${SCRIPT_DIR}/utils.bash"

shopt -s extglob

help() {
    echo -e "${BOLD}Usage:${GREEN} $(basename "$0") ${RESET}${RED} <apptainer_app_dir> <python_venv_dir>${RESET}"
    exit 1
}

if [ "$#" -ne 2 ]; then
    help
fi

APP_DIR="$1"
PYTHON_VENV_DIR="$2"

#Cleaning to lighten the image
apt purge -y git build-essential wget curl software-properties-common cmake patchelf clang libopenmpi-dev ${python_version}-dev python3
apt autoclean -y && apt autoremove --purge -y && apt clean -y && apt autopurge -y
rm -rf /var/lib/apt/lists/*

#Remove tools only needed for build
rm -rf CMakeCache.txt CMakeFiles Makefile cmake_install.cmake
rm -rf ${APP_DIR}/tensorial/!(src)
rm -rf ${APP_DIR}/chemtrain/!(chemtrain-deploy|chemtrain|jax_md_mod)
rm -rf ${APP_DIR}/cmake
rm -rf ${APP_DIR}/src/!(CHEMTRAIN-DEPLOY)
rm -rf ${APP_DIR}/build/styles ${APP_DIR}/build/include

#Clean model-export python directory
rm -rf ${APP_DIR}/python/!(model-export)
rm -rf ${APP_DIR}/python/model-export/*test*
rm -rf ${APP_DIR}/python/model-export/__pycache__

#Pip cleaning
pip cache purge
find ${APP_DIR} -type d -name __pycache__ -prune -exec rm -rf {} +
find ${PYTHON_VENV_DIR} -type d \( -name tests -o -name test \) -prune -exec rm -rf {} +
find ${PYTHON_VENV_DIR} -name '*.a' -delete
find ${PYTHON_VENV_DIR} -name '*.pyc' -delete
rm -rf ${PYTHON_VENV_DIR}/lib/python*/site-packages/nvidia/*/include
rm -rf ${PYTHON_VENV_DIR}/share

#Remove unused Python packages
rm -rf ${PYTHON_VENV_DIR}/bin/ty
rm -rf ${PYTHON_VENV_DIR}/bin/ruff
#System cleaning
rm -rf /var/lib/apt/lists/* /usr/share
rm -rf /root/.cache /root/.local

