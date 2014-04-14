## /*
 #  @usage myman_list [<index-name>]
 #
 #  @description
 #  This file is intended to list all of the keywords which have gsman comments
 #  associated with them, and will display using "gsman <keyword>".
 #  description@
 #
 #  @notes
 #  - This file is not intended to be used by itself.
 #  notes@
 #
 #  @dependencies
 #  functionsh/functions/__menu.sh
 #  dependencies@
 #
 #  @file gsman_list.sh
 ## */

function myman_list {
    declare -a manifests
    declare -a indexes
    declare -a cmds
    local indexName docsPath


    [ -n "$1" ] && indexName="$1"

    if [ -z "$indexName" ]; then
        # all
        for index in $(ls "$myman_docs_path"); do
            indexes[${#indexes[@]}]="$index"
        done

        if [ ${#indexes[@]} == 1 ]; then
            indexName="${indexes[0]}"

        elif __menu --prompt="Please choose a project" ${indexes[@]}; then
            if [ -n "$_menu_sel_value" ]; then
                indexName="$_menu_sel_value"
            else
                # user aborted
                return 0
            fi
        fi
    fi

    docsPath="${myman_docs_path}/${indexName}"
    if [ ! -d "$docsPath" ]; then
        echo "${E}  Could not find documentation for ${COL_CYAN}${indexName}  ${X}"
        return 1
    fi

    # build command array that will get sent to the __menu function
    while read line; do
        cmds[${#cmds[@]}]=${line%%:*}
    done < "${docsPath}/manifest"

    if __menu --prompt="Choose a command to view it's documentation" "${cmds[@]}"; then
        if [ -n "$_menu_sel_value" ]; then
            myman_parse "$_menu_sel_value"
            clear
        else
            echo
            echo "  Until next time..."
        fi
    else
        echo ${E}"  There was an error listing the \`myman\` commands. Exiting...  "${X}
    fi

}
export -f myman_list
