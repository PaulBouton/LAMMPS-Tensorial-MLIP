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

#Cleaning apt packages
apt-get purge -y git build-essential wget curl software-properties-common cmake patchelf clang libopenmpi-dev ${python_version}-dev python3
apt-get autoclean -y
apt-get autoremove --purge -y
apt-get clean -y
rm -rf /var/lib/apt/lists/*

#Clean chemtrain directory
rm -rf "${APP_DIR}"/chemtrain/!(chemtrain|jax_md_mod)

#Remove tools only needed for build
rm -rf CMakeCache.txt CMakeFiles Makefile cmake_install.cmake
rm -rf "${APP_DIR}"/tensorial/!(src)
rm -rf "${APP_DIR}"/cmake
rm -rf "${APP_DIR}"/src/!(CHEMTRAIN-DEPLOY)
rm -rf "${APP_DIR}"/build/styles "${APP_DIR}"/build/include

#Clean model-export python directory
rm -rf "${APP_DIR}"/python/!(model-export)
rm -rf "${APP_DIR}"/python/model-export/*test*
rm -rf "${APP_DIR}"/python/model-export/__pycache__

#Pip cleaning
pip cache purge
find "${APP_DIR}" -type d -name __pycache__ -prune -exec rm -rf {} +
find "${PYTHON_VENV_DIR}" -type d \( -name tests -o -name test \) -prune -exec rm -rf {} +
find "${PYTHON_VENV_DIR}" -name '*.a' -delete
find "${PYTHON_VENV_DIR}" -name '*.pyc' -delete
rm -rf "${PYTHON_VENV_DIR}"/lib/python*/site-packages/nvidia/*/include
rm -rf "${PYTHON_VENV_DIR}"/share

#Remove Python test and code coverage packages
pip uninstall -y pytest pytest_cov pytest_mock pytest_env \
                 pytest_codspeed coverage pluggy iniconfig

#Remove Jupyter packages
pip uninstall -y \
  notebook notebook_shim jupyter jupyter_core jupyter_client jupyter_server jupyterlab jupyterlab_pygments \
  ipykernel ipywidgets widgetsnbextension comm debugpy nest_asyncio2 \
  nbconvert nbformat nbclient fastjsonschema \
  terminado send2trash prometheus_client websocket_client json5 async_lru python_json_logger \
  mistune bleach webencodings tinycss2 defusedxml pandocfilters pandoc \
  fqdn isoduration arrow jsonpointer rfc3339_validator rfc3986_validator rfc3987_syntax uri_template webcolors lark \
  jupyter_builder jupyter_console jupyter_events jupyter_lsp jupyter_server_terminals \
  jupyterlab_server jupyterlab_widgets argon2_cffi argon2_cffi_bindings

#Remove Ipython related packages
pip uninstall -y ipython ipython_pygments_lexers matplotlib_inline jedi parso prompt_toolkit wcwidth \
  pexpect ptyprocess stack_data executing asttokens pure_eval

#Remove Python doc packages
pip uninstall -y \
  sphinx sphinx_rtd_theme sphinx_autodoc_typehints sphinx_autobuild sphinx_copybutton sphinx_design \
  sphinxcontrib_applehelp sphinxcontrib_devhelp sphinxcontrib_htmlhelp sphinxcontrib_jsmath \
  sphinxcontrib_qthelp sphinxcontrib_serializinghtml dataclasses \
  myst_parser mdit_py_plugins nbsphinx furo pydata_sphinx_theme \
  alabaster accessible_pygments imagesize roman_numerals snowballstemmer babel \
  starlette uvicorn uvloop watchfiles websockets docutils sphinx_paramlinks

#Remove Python dev tools Packages
pip uninstall -y \
  pylint astroid isort mccabe mypy_extensions tomlkit \
  pre_commit identify cfgv nodeenv virtualenv distlib python_discovery \
  flit flit_core build tomli_w ruff ty

#System cleaning
# shellcheck disable=SC2114
rm -rf /usr/share
rm -rf /root/.cache
rm -rf /root/.local

cd "${CUR_DIR}"

