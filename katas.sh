#!/usr/bin/env bash

KATAS_HOME="$HOME/.katas"
KATAS_DIR="$HOME/katas"

system_path="$HOME/.katas"
katas_bin_path="${system_path}/bin/katas"
mentors_path="${system_path}/mentor"
scripts_path="${system_path}/scripts"

dojo_script="${script_path}/dojo.py"

base_path="$HOME/katas"
dojo_path="${base_path}/dojo"

INSTALL_KATAS=0
if [ "$1" = "install_katas" ]; then
    INSTALL_KATAS=1
elif [ "$1" = "install" -a "$2" = "katas" ]; then
    INSTALL_KATAS=1
fi

if [ INSTALL_KATAS = 1 ]; then
    if [ -x "${katas_bin_path}" ]; then
        exit 0
    else
        mkdir -p "${system_path}/bin"
        \curl -sSL -o "$katas_bin_path" https://raw.githubusercontent.com/kataslog/katas/master/katas
        chmod +x "${katas_bin_path}"

        echo "Running initial setup"
        exec "${katas_bin_path}" setup
    fi

    exit 0
fi

################################

function usage() {
    me=$(basename $0)

    echo "$me commands:"
    printf "%b" "    list dojo\n"
    printf "%b" "    list <dojo>\n"
    printf "%b" "    fetch <dojo>\n"
    printf "%b" "    hint <dojo> <kata_number> [--all]\n"
    printf "%b" "    test <dojo> [--number=<kata_number>]\n"
}

function setup() {
    mkdir -p "$KATAS_HOME/"{bin,scripts,mentors}

    \curl -sSL -o "$dojo_script" https://raw.githubusercontent.com/kataslog/katas/master/scripts/dojo.py
}

function validate_install() {
    if [ ! -d "${system_path}/bin" \
      -o ! -d "${system_path}/scripts" \
      -o ! -d "${system_path}/mentors" ]; then
        echo "Please run $me setup"
        exit 1
    fi
}

function dojo_list() {
    python "$dojo_script"
}

function dojo_list_known() {
    echo "knowns"
}

function dojo_katas_list() {
    dojo_name="$1"
}

################################

action="$1"
shift

if [ -z "$action" ]; then
    usage
    exit 0
fi

if [ ! "$action" = "setup" ]; then
    validate_install
elif [ ! "$action" = "instal" -a "$1" = "katas" ]; then
    validate_install
fi

case $action in
    list)
        [[ -z "$1" ]] && usage && exit 1
        if [ "$1" = "dojo" -a "$2" = "known" ]
        then
            dojo_list_known
        elif [ "$1" = "dojo" ]
        then
            dojo_list
        else
            dojo_katas_list "$1"
        fi
        ;;
    setup|reinstall)
        setup
        exit
        ;;
    *)
        usage
        exit
        ;;
esac
