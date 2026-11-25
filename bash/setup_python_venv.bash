#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CUR_DIR="$(pwd)"
source "${SCRIPT_DIR}/utils.bash"

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

#Reset venv
rm -rf "${VENV_DIR}"
mkdir "${VENV_DIR}"

${python_version} -m venv "${VENV_DIR}"
source "${VENV_DIR}/bin/activate"

#Install needed pip
pip install -e "${SCRIPT_DIR}/../chemtrain"
pip install -e "${SCRIPT_DIR}/../chemtrain[test]"

if [[ "$TARGET_ARCH" == "cuda" ]]; then
    pip install -e "${SCRIPT_DIR}/../chemtrain[cuda${MAIN_CUDA_VERSION}]"
    pip install nvidia-cuda-nvcc-cu${MAIN_CUDA_VERSION}==${pip_cuda_version}
fi

pip install -e "${SCRIPT_DIR}/../tensorial[dev]"
pip install -e "${SCRIPT_DIR}/../tensorial[docs]"

if [[ "$TARGET_ARCH" == "cuda" ]]; then
    #Use coherent jax lib versions between chemtrain (jax[cuda]) and tensorial (jax)
    if [[ "$TARGET_ARCH" == "cuda" ]]; then
        #Get The Jaxlib version (non cuda one) from tensorial
        jaxlib_version="$(python -c 'import jaxlib; print(jaxlib.__version__)')"

        #Remove unused tensorial jax versions (jax, jaxlib and the cuda plugin/pjrt).
        unused_jax="$(pip freeze \
            | grep -E '^(jax|jaxlib|jax-cuda1[23]-(plugin|pjrt))==' \
            | grep -v "==${jaxlib_version}$" \
            | cut -d'=' -f1 || true)"

        if [[ -n "${unused_jax}" ]]; then
            echo -e "${YELLOW}Removing unused jax versions, keeping ${jaxlib_version}${RESET}"
            pip uninstall -y ${unused_jax}
        fi
    #Install jax[cuda] with the same jax version that tensorial
    pip install "jax[cuda${MAIN_CUDA_VERSION}]==${jaxlib_version}"
    fi
fi

pip install -r "${SCRIPT_DIR}/../requirements.txt"
pip install --upgrade pip
