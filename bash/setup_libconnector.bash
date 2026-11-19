#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CUR_DIR="$(pwd)"

source "${SCRIPT_DIR}/utils.bash"

#Exit on Error
set -e

#---------------HERE STARTS THE SCRIPT---------------

help() {
    echo -e "${BOLD}Usage:${GREEN} $(basename "$0") ${RESET}${RED}<python_venv_path> <cpu/cuda>${RESET}"
    exit 1
}

if [ "$#" -ne 2 ]; then
    help
fi

VENV_DIR="$1"
TARGET_ARCH="$2"

#Activate python venv
source ${VENV_DIR}/bin/activate

#Setup build options
build_options="--output_path=out --install_location=lib"
#Bazel specific options
build_options="${build_options} --bazel_options=--discard_analysis_cache"
build_options="${build_options} --bazel_option=--spawn_strategy=local"
build_options="${build_options} --bazel_options=--local_resources=memory=HOST_RAM*.6" # Restrict RAM usage to avoid PC freezes

cd ${SCRIPT_DIR}/../chemtrain/chemtrain-deploy

if [[ "$TARGET_ARCH" == "cpu" ]]; then
    python build.py ${build_options} --build_cpu_pjrt_plugin
elif [[ "$TARGET_ARCH" == "cuda" ]]; then
    python build.py ${build_options} \
      --enable_cuda \
      --build_gpu_pjrt_plugin \
      --cuda_version=${cuda_version} \
      --cudnn_version=${cudnn_version} \
      --cuda_compute_capabilities=${cuda_compute_version}
else
    git checkout ${SCRIPT_DIR}/../chemtrain
    echo -e "Invalid target Architecture!"
    exit 1
fi

cd ${CUR_DIR}
