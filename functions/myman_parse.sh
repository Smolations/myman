## /* @function
 #  @usage myman_parse <command-name>
 #
 #  @output true
 #
 #  @description
 #  This script searches the command indexes for the specified command.
 #  Once the command is found, the help file is output to the screen
 #  with a colored interface. If more than one doc is found for any given
 #  <command-name>, a menu is presented to the user so that they may choose
 #  which documentation to show.
 #  description@
 #
 #  @notes
 #  - This script is called from gsman.sh and is not intended to be a
 #  standalone script.
 #  notes@
 #
 #  @dependencies
 #  `less`
 #  `egrep`
 #  lib/functionsh/functions/__menu.sh
 #  dependencies@
 #
 #  @returns
 #  0 - successful execution of function
 #  1 - no arguments passed to function
 #  2 - could not find document containing documentation (or user aborts)
 #  returns@
 #
 #  @file functions/myman_parse.sh
 ## */

function myman_parse {
    [ $# == 0 ] && return 1

    local cmd="$1" G=${COL_GREEN}
    local indexName docsPath key pair CATEGORY
    declare -a paths
    declare -a categories
    declare -a docOptions
    declare -a menuOpts


    # loop through each config line. if an index name was passed, skip
    # all non-matching lines.
    while read pair; do

        key="${pair%%=*}"
        ! egrep -q '^index\.[^.]+\.src$' <<< "$key" && continue

        indexName="${key%.src}"
        indexName="${indexName#index.}"

        docsPath="${myman_docs_path}/${indexName}"
        manifest="${docsPath}/manifest"

        while read entry; do
            if egrep -q "^${cmd}:" <<< "$entry"; then
                docPath="${docsPath}/${entry#*:}"
                if [ -s "$docPath" ]; then
                    menuOption="${docPath#${myman_docs_path}/}"
                    menuOption="${menuOption%/*}"
                    menuOption=$(sed 's;/;:;g' <<< "$menuOption")
                    category="${entry%%/*}"
                    category="${category#*:}"

                    menuOpts[${#menuOpts[@]}]="$menuOption"
                    paths[${#paths[@]}]="$docPath"
                    categories[${#categories[@]}]="$category"
                fi
            fi
        done < "$manifest"

    done < "${myman_path}/.cfg/cfg.parsed"


    if [ ${#paths[@]} -gt 1 ]; then
        if __menu --prompt="More than one \`${indexName}\` found. Choose one" ${menuOpts[@]}; then
            if egrep -q '^[0-9]+$' <<< "$_menu_sel_index"; then
                (( ndx = _menu_sel_index - 1 ))
                category="${categories[${ndx}]}"
                docPath="${paths[${ndx}]}"
            else
                return 0
            fi
        fi
    fi


    # display documentation
    if [ -s "$docPath" ]; then
        # use file descriptors to send the "curried" document to
        # a temp file, then display the doc with `less`
        exec 4>&1
        exec > "$myman_tmp"

        echo
        echo "${G}## /* ${X}"
        echo "${G}#      myman    ${COL_CYAN}@command:  ${X}${cmd}${X}"
        echo "${G}#               ${COL_CYAN}@category: ${X}${category}"
        echo "${G}## */ ${X}"
        echo
        cat "$docPath"
        echo

        exec 1>&4 4>&-

        less --force --RAW-CONTROL-CHARS "$myman_tmp"
        rm -f "$myman_tmp"

    else
        echo "${E}  `myman` cannot find the documentation for this command.  ${X}"
        return 2
    fi
}
export -f myman_parse
