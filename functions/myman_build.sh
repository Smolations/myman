## /* @function
 #  @usage myman_build [<index-name>]
 #
 #  @output true
 #
 #  @description
 #  This script is called when the --build-index option is passed to the
 #  gsman command. It cycles through all paths which have been specified
 #  to have gcsommented files in them and creates the help files for those
 #  commands and adds them to an index which is easily parsed when a user
 #  runs "myman <command>".
 #  description@
 #
 #  @notes
 #  - This function is intended to be used only by `myman`.
 #  notes@
 #
 #  @dependencies
 #  `egrep`
 #  awk/myman_parse.awk
 #  functions/myman_cfg.sh
 #  dependencies@
 #
 #  @returns
 #  0 - successful execution of function
 #  1 - possible invalid index. docs path could not be found
 #  returns@
 #
 #  @file functions/myman_build.sh
 ## */

function myman_build {
    local indexName docsPath key justOne=false

    if [ -n "$1" ]; then
        indexName="$1"
        docsPath="${myman_docs_path}/${indexName}"

        if [ ! -d "${docsPath}" ]; then
            echo "${E}  Cannot build index. Docs path does not exist:  ${X}"
            echo "${E}    ${docsPath}  ${X}"
            return 1
        fi
    fi

    # loop through each config line. if an index name was passed, skip
    # all non-matching lines.
    while read pair; do
        key=
        if [ -n "$indexName" ]; then
            key="index.${indexName}.src"
            ! egrep -q "^${key}" <<< "$pair" && continue
            justOne=true

        else
            key="${pair%%=*}"
            ! egrep -q '^index\.[^.]+\.src$' <<< "$key" && continue

            indexName="${key%.src}"
            indexName="${indexName#index.}"

            docsPath="${myman_docs_path}/${indexName}"
        fi

        echo "Building \`myman\` index for ${B}${COL_MAGENTA}${indexName}${X}"

        srcPath=$(myman_cfg "$key")
        manifest="${docsPath}/manifest"
        tmp="${docsPath}/tmp"

        : > "$manifest"

        for file in "$srcPath"/*; do
            if [ ! -d "$file" ]; then
                # parse: /Users/smola/Workspaces/myman/functions/myman_cfg.sh
                # echo "parse: $file"
                j=0
                docType=""
                docName=""
                awk -f "${myman_awk_path}/myman_parse.awk" "$file" > "$tmp"
                # subl "$tmp"
                # cat "$tmp"
                # break

                if grep -q '@usage' "$tmp"; then

                    # added IFS= here to preserve the leading whitespace in the docs
                    while IFS= read line; do

                        # first line -- type:...
                        if (( j == 0 )); then
                            docType="${line:5}"
                            [ -z "$docType" ] && docType="main"
                            docPath="${docsPath}/${docType}"

                            if [ ! -d "$docPath" ]; then
                                mkdir -p "$docPath"
                            fi

                        # second line -- name:...
                        elif (( j == 1 )); then
                            docName="${line:5}"
                            if [ -n "$docName" ] && [ "$docName" != "source" ]; then
                                fileName="${docPath}/${docName}.txt"

                                # relative file name. this is how gsman was originally
                                # storing references to commands. manifest?
                                rFileName="${fileName#${docsPath}/}"
                                echo "${docName}:${rFileName}" >> "$manifest"
                            else
                                break
                            fi

                        # all other lines are the gsman comments
                        elif [ -n "$rFileName" ]; then
                            (( j == 2 )) && : > "$fileName"
                            echo "$line" >> "$fileName"
                        fi

                        (( j++ ))

                    done < "$tmp"

                else
                    echo " ${COL_CYAN}@usage${X} missing for:  ${file}"
                fi
            fi
            # break
        done

        $justOne && break
    done < "${myman_path}/.cfg/cfg.parsed"

    # build the indexes for each path
    # for path in ${paths[@]}; do
    # done

    return
    #################################

    # user might want to build one of two indexes
    if [ -n "$1" ]; then
        [ "$1" == "user" ] && paths[0]="${gsman_paths_user}" && userOnly=true
        [ "$1" == "main" ] && paths[0]="${gsman_paths_default}" && mainOnly=true
    fi

    # if paths has an element, then the passed-in argument was validated.
    # otherwise, build all by default.
    if [ ${#paths[@]} -eq 0 ]; then
        paths[0]="${gsman_paths_default}"
        paths[1]="${gsman_paths_user}"
    fi

    docPath="${gitscripts_doc_path}"
    tmp="${gitscripts_temp_path}gsmantemp"
    [ ! -d "${gitscripts_temp_path}" ] && mkdir "${gitscripts_temp_path}"

    echo ${X}
    echo ${H1}${H1HL}
    echo "  Beginning GSMan index build. Please wait...  "
    echo ${H1HL}${X}
    echo

    for (( i = 0; i < ${#paths[@]}; i++ )); do
        docPathPrefix=
        { [ $userOnly ] || [ $i -eq 1 ]; } && docPathPrefix="user/"
        docPath="${docPath}${docPathPrefix}"
        [ ! -d "$docPath" ] && mkdir "$docPath"
        docIndex="${docPath}gsman_index.txt"
        : > "$docIndex"

        for path in ${paths[i]}; do
            echo "Indexing files in: $path"

            for file in "$path"*; do
                if [ ! -d "$file" ]; then
                    j=0
                    docType=""
                    docName=""
                    awk -f "${gitscripts_awk_path}gsman_parse.awk" "${file}" > "$tmp"
                    while read line; do
                        # first line -- type:...
                        if [ $j -eq 0 ]; then
                            docType="${line:5}"
                            [ -z "$docType" ] && docType="main"
                            if [ ! -d "${docPath}${docType}" ]; then
                                mkdir "${docPath}${docType}"
                            fi

                        # second line -- name:...
                        elif [ $j -eq 1 ]; then
                            docName="${line:5}"
                            if [ -n "$docName" ] && [ "$docName" != "source" ]; then
                                fileName="${docPath}${docType}/${docName}.txt"
                                rFileName="${fileName#${gitscripts_path}}"
                                echo "${docName}:${rFileName}" >> "$docIndex"
                            else
                                break
                            fi

                        # all other lines are the gsman comments
                        elif [ -n "$rFileName" ]; then
                            [ $j -eq 2 ] && : > "$fileName"
                            echo "$line" >> "$fileName"

                        fi

                        (( j++ ))
                    done <"$tmp"
                fi
            done

        done

    done

    # clean up
    rm "$tmp"

}
export -f myman_build
