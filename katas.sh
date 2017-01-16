#!/usr/bin/env bash

KATAS_HOME="$HOME/.katas"
KATAS_DIR="$HOME/katas"
KATAS_SCRIPTS_PATH="$KATAS_HOME/scripts"

KATAS_ROOT_URL="https://raw.githubusercontent.com/kataslog/katas/master"

system_path="$HOME/.katas"
katas_bin_path="${system_path}/bin/katas"
mentors_path="${system_path}/mentor"
scripts_path="${system_path}/scripts"

dojo_script="${scripts_path}/dojo.py"
sensei_script="${scripts_path}/sensei.py"
watchman_script="${scripts_path}/watchman.py"

base_path="$HOME/katas"
dojo_path="${base_path}/dojo"

INSTALL_KATAS=0
if [ "$1" = "install_katas" ]; then
    INSTALL_KATAS=1
elif [ "$1" = "install" -a "$2" = "katas" ]; then
    INSTALL_KATAS=1
fi

if [ "$INSTALL_KATAS" = 1 ]; then
    if [ -x "${katas_bin_path}" ]; then
        exit 0
    else
        mkdir -p "${system_path}/bin"
        \curl -sSL -o "$katas_bin_path" "$KATAS_ROOT_URL/katas.sh"
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
    printf "%b" "    list dojo                       - show list of available dojo\n"
    printf "%b" "              [--all] [-a]            * all\n"
    printf "%b" "          [--fetched] [-f]            * only fetched\n"
    printf "%b" "\n"
    printf "%b" "    list <dojo>                     - show list of katas for dojo\n"
    printf "%b" "                [--version] [-v]      * version of dojo\n"
    printf "%b" "                    [--all] [-a]      * all\n"
    printf "%b" "             [--unresolved] [-u]      * unresolved\n"
    printf "%b" "                   [--done] [-d]      * done\n"
    printf "%b" "                   [--time] [-t]      * sorting by time resolution\n"
    printf "%b" "          [--sort=acs/desc]           * sorting direction\n"
    printf "%b" "             [--level=0..2]           * filter by level\n"
    printf "%b" "\n"
    printf "%b" "    default <dojo>                  - use dojo as default for operations list/hint/test/open\n"
    printf "%b" "\n"
    printf "%b" "    fetch <dojo>                    - fetch katas for dojo\n"
    printf "%b" "\n"
    printf "%b" "    update [<dojo>] [--all] [-a]    - update single dojo or all\n"
    printf "%b" "\n"
    printf "%b" "    hint <dojo> <kata>              - dispalay hint for kata (if exists)\n"
    printf "%b" "                   [--all] [-a]       * all hints for kata\n"
    printf "%b" "\n"
    printf "%b" "    test <dojo> [<kata>]            - runt tests for single kata or for all dojo\n"
    printf "%b" "\n"
    printf "%b" "    open <dojo> [<kata>]            - open dojo or selected kata\n"
    printf "%b" "                [--random] [-r]       * random kata from dojo\n"
    printf "%b" "             [--random=<level>]       * with filtering by level\n"
}

function create_katas_env_scripts() {

    cat <<"EOF"> "$KATAS_SCRIPTS_PATH/katas"
source "$HOME/.katas/scripts/katas.bash"
EOF

    # Bash and Zsh
    cat <<"EOF"> "$KATAS_SCRIPTS_PATH/katas.bash"
KATAS_HOME="$HOME/.katas"
export PATH=$PATH:$KATAS_HOME/bin

function katas(){
  $HOME/.katas/bin/katas $*
}
EOF
}

function setup() {

    grep -sv '^#' ~/.bashrc | grep -isq katas
    [[ $? = 0 ]] && in_bashrc=$HOME/.bashrc
    grep -sv '^#' ~/.profile | grep -isq katas
    [[ $? = 0 ]] && in_profile=$HOME/.profile
    grep -sv '^#' ~/.bash_profile | grep -isq katas
    [[ $? = 0 ]] && in_bash_profile=$HOME/.bash_profile
    grep -sv '^#' ~/.zshrc | grep -isq katas
    [[ $? = 0 ]] && in_zshrc=$HOME/.zshrc
    grep -sv '^#' ~/.zsh_profile | grep -isq katas
    [[ $? = 0 ]] && in_zsh_profile=$HOME/.zsh_profile

    str=""
    for s in $in_bashrc $in_profile $in_bash_profile $in_zshrc $in_zsh_profile ; do
        [[ -z "$str" ]] && str="$s" && str="${str}, $s"
    done
    if [ -z "$str" ] ; then
        echo "    Katas source line not found in ~/.bashrc, ~/.bash_profile, ~/.profile, ~/.zshrc, or ~/.zsh_profile"
        source_line_found=0
    else
        echo "    Katas sourcing line found in: ${str}"
        source_line_found=1
    fi

    mkdir -p "$KATAS_HOME/"{bin,scripts,mentors}

    \curl -sSL -o "$dojo_script" "$KATAS_ROOT_URL/scripts/dojo.py"
    \curl -sSL -o "$sensei_script" "$KATAS_ROOT_URL/scripts/sensei.py"
    \curl -sSL -o "$watchman_script" "$KATAS_ROOT_URL/scripts/watchman.py"

    create_katas_env_scripts

    if [ $source_line_found = 0 ]; then
        echo "    Add the following to your shell's config file (.bashrc/.zshrc):"
        echo "        test -s \"$HOME/.katas/scripts/katas\" && source \"$HOME/.katas/scripts/katas\""
    fi
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
    python "$dojo_script" "list_dojo" --all
}

function dojo_list_known() {
    python "$dojo_script" "list_dojo" --fetched
}

function dojo_katas_list() {
    dojo="$1"
    filter="$2"
    time="$3"
    sort="$4"
    difficulty="$5"
    echo "katas list ${dojo} ${filter} ${time} ${sort} ${difficulty}"
    python "$dojo_script" "list_katas" -dojo="$dojo"
}

function dojo_use_default() {
    dojo="$1"
    echo "use as default ${dojo}"
    python "$dojo_script" "use_default" -dojo="$dojo"
}

function dojo_fetch() {
    dojo="$1"
    echo "dojo fetch ${dojo}"
    python "$watchman_script" "fetch_dojo" --dojo="$1"
}

function dojo_update() {
    dojo="$1"
    echo "dojo update ${dojo}"
    python "$watchman_script" "update_dojo" --dojo="$1"
}

function dojo_hint() {
    dojo="$1"
    kata="$2"
    all="$3"
    echo "hint ${dojo} ${kata} ${all}"
    python "$sensei_script" "hint" --dojo="$dojo" --kata="$kata" --all
}

function dojo_test() {
    dojo="$1"
    kata="$2"
    echo "test ${dojo} ${kata}"
    python "$sensei_script" "test" --dojo="$dojo" --kata="$kata"
}

function dojo_open() {
    dojo="$1"
    kata="$2"
    level="$3"
    random="$4"
    echo "open ${dojo} ${kata} ${level} ${random}"
    python "$dojo_script" "open" --dojo="$dojo" --kata="$kata"
}

function clear() {
    rm -rf "$KATAS_HOME"
}

################################

action="$1"
shift

if [ -z "$action" ] ; then
    usage
    exit 0
fi

if [ ! "$action" = "setup" ] ; then
    validate_install
elif [ ! "$action" = "instal" -a "$1" = "katas" ] ; then
    validate_install
fi

case $action in
    list)
        [[ -z "$1" ]] && usage && exit 1

        if [[ "$1" = "dojo" ]]; then
            shift
            if [[ -z "$1" ]]; then
                dojo_list_known
            else
                case "$1" in
                    -f|--fetched)
                        dojo_list_known
                        ;;
                    -a|--all)
                        dojo_list
                        ;;
                    *)
                        usage
                        exit 1
                        ;;
                esac
            fi
        else
            dojo="$1"
            shift

            f_all=0
            f_done=0
            f_unresolved=0
            level=-1
            time=0
            sort=0

            while test $# -gt 0; do
                case "$1" in
                    --version|-v)
                        shift
                        ;;
                    --all|-a)
                        f_all=1
                        shift
                        ;;
                    --done|-d)
                        f_done=1
                        shift
                        ;;
                    --unresolved|-u)
                        f_unresolved=1
                        shift
                        ;;
                    --time|-t)
                        time=1
                        shift
                        ;;
                    --sort*)
                        direction=`echo $1 | sed -e 's/^[^=]*=//g'`
                        case $direction in
                            asc)
                                sort=1
                                ;;
                            desc)
                                sort=-1
                                ;;
                            *)
                                sort=0
                                ;;
                        esac
                        shift
                        ;;
                    --level*)
                        l=`echo $1 | sed -e 's/^[^=]*=//g'`
                        case $l in
                            easy|0)
                                level=0
                                ;;
                            medium|1)
                                level=1
                                ;;
                            hard|2)
                                level=2
                                ;;
                            *)
                                level=-1
                                ;;
                        esac
                        shift
                        ;;
                    *)
                        usage
                        exit 1
                        ;;
                esac
            done

            ((f_list=f_all+f_done+f_unresolved))
            if [[ $f_list -gt 1 ]]; then
                usage
                exit 1
            else
                filter=0
                if [[ $f_all -ne 0 ]]; then
                    filter=0
                fi
                if [[ $f_done -ne 0 ]]; then
                    filter=2
                fi
                if [[ $f_unresolved -ne 0 ]]; then
                    filter=1
                fi

                dojo_katas_list "$dojo" "$filter" "$time" "$sort" "$level"
            fi
        fi
        ;;
    default)
        [[ -z "$1" ]] && usage && exit 1
        dojo_use_default "$1"
        ;;
    fetch)
        [[ -z "$1" ]] && usage && exit 1
        dojo_fetch "$1"
        ;;
    update)
        [[ -z "$1" ]] && usage && exit 1
        dojo_update "$1"
        ;;
    hint|open|test)
        [[ -z "$1" ]] && usage && exit 1

        kata=
        kata_count=0
        all=
        level=
        random=
        dojo="$1"
        shift

        while [[ $# -gt 0 ]]; do
            case "$1" in
                -a|--all)
                    all=1
                    shift
                    ;;
                -r|--random)
                    random=1
                    shift
                    ;;
                --level*)
                    l=`echo $1 | sed -e 's/^[^=]*=//g'`
                    case "$l" in
                        0|easy)
                            level=0
                            ;;
                        1|medium)
                            level=1
                            ;;
                        2|hard)
                            level=2
                            ;;
                    esac
                    shift
                    ;;
                *)
                    kata="$1"
                    ((kata_count++))
                    shift
                    ;;
            esac
        done

        if [[ $kata_count -gt 1 ]]; then
            usage
            echo "katas count"
            exit 1
        fi

        if [[ "$action" = "hint" ]]; then
            [[ -z "$kata" ]] && usage && exit 1
            dojo_hint "$dojo" "$kata" "$all"
        elif [[ "$action" = "open" ]]; then
            [[ -n "$level" ]] && [[ -z "$random" ]] && usage && exit 1
            [[ -n "$kata" ]] && [[ -n "$random" ]] && usage && exit 1
            dojo_open "$dojo" "$kata" "$level" "$random"
        else
            dojo_test "$dojo" "$kata"
        fi
        ;;
    setup|reinstall)
        setup
        exit
        ;;
    clear)
        clear
        exit
        ;;
    *)
        usage
        exit
        ;;
esac
