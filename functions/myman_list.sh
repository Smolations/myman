## /* @function
 #  @usage myman_list [<index-name>]
 #
 #  @output true
 #
 #  @description
 #  This function is intended to list all of the commands which have myman comments
 #  associated with them, and will display using "myman <index-name>".
 #  description@
 #
 #  @notes
 #  - This function is intended to be used only by `myman`.
 #  notes@
 #
 #  @dependencies
 #  functions/myman_parse.sh
 #  lib/functionsh/functions/__menu.sh
 #  dependencies@
 #
 #  @returns
 #  0 - function returned successfully
 #  1 - "choose project" menu entry invalid
 #  2 - could not find documentation for given index
 #  4 - "choose cammond" menu entry invalid
 #  returns@
 #
 #  @file functions/myman_list.sh
 ## */

function myman_list {
    declare -a manifests indexes cmds
    local indexName docsPath

    # 1st argument is the index (project) name
    [ -n "$1" ] && indexName="$1"

    # if no index name is given, show a list of indexes first
    if [ -z "$indexName" ]; then
        for index in $(ls "$myman_docs_path"); do
            indexes[${#indexes[@]}]="$index"
        done

        if [ ${#indexes[@]} == 1 ]; then
            indexName="${indexes[0]}"

        elif __menu --prompt="Please choose a project" ${indexes[@]}; then
            if [ -n "$_menu_sel_value" ]; then
                indexName="$_menu_sel_value"
                echo
                echo "-----${B}${COL_GREEN}<//>${X}-------------------------------------------------------"

            else
                # user aborted
                return 0
            fi
        else
            # bad menu selection
            return 1
        fi
    fi

    docsPath="${myman_docs_path}/${indexName}"
    if [ ! -d "$docsPath" ]; then
        echo "${E}  Could not find documentation for ${COL_CYAN}${indexName}  ${X}"
        return 2
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
        echo "${E}  There was an error listing the \`myman\` commands. Exiting...  ${X}"
        return 4
    fi

    return 0
}
export -f myman_list
