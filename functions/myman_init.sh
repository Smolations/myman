## /* @function
 #  @usage myman_init [<index-name>] [<index-path>]
 #
 #  @description
 #  When a user has a project with documentation, that documentation may be
 #  located in many areas across the project. Or, maybe the project is organized in
 #  such a way that all files needing documentation are located within a single
 #  directory. `myman_init` is flexible when it comes to telling `myman` where the
 #  documentation is.
 #
 #  <index-name>
 #      This is how `myman` identifies the body of documentation created from files
 #      in the <index-path>. This is also how you will filter documentation choices.
 #      If not given, it will match the name of the folder to be indexed.
 #
 #  <index-path>
 #      The path that `myman` will recursively search for documentation. If this is
 #      not provided, `myman` will index the current working directory.
 #  description@
 #
 #  @notes
 #  - Some abiguous use cases exist. For example, if the user doesn't opt to name
 #  the index and the desired docs folder is in the current directory, that user
 #  could initialize the index thusly:
 #      myman_init docs
 #
 #  In cases like this, "lib" will first be checked to see if it is a folder in the
 #  current directory. If it is not, it will be treated as the <index-name> and the
 #  current directory will be the <index-path>.
 #
 #  It is recommended that the user ALWAYS specify the <index-name>.
 #  notes@
 #
 #  @dependencies
 #  functions/myman_cfg.sh
 #  functions/myman_build.sh
 #  dependencies@
 #
 #  @returns
 #  0 - successful execution of function
 #  1 - given <index-path> does not exist
 #  2 - given <index-name> already has generated docs
 #  4 - could not create folder to contain docs
 #  returns@
 #
 #  @file functions/myman_init.sh
 ## */

function myman_init {
    local indexPath=$(pwd)
    local indexName="${indexPath##*/}"
    local docsHome

    case $# in
        2)
            indexName="$1"
            indexPath="$2"
            ;;

        1)
            if grep -q '/' <<< "$1"; then
                indexPath="$1"
                indexName="${indexPath##*/}"

            elif [ -d "$1" ]; then
                indexName="$1"
                indexPath="$indexName"
            fi
            ;;

        0)
            true;;

        *)
            indexName="$1"
            shift
            indexPath="$@"
    esac

    if [ ! -d "$indexPath" ]; then
        echo "${E}  Docs path does not exist: ${indexPath}  ${X}"
        return 1
    fi

    indexPath=$(cd "$indexPath"; pwd)
    # echo; echo "indexPath = ${indexPath}"

    docsHome="${myman_docs_path}/${indexName}"
    if [ -d "$docsHome" ]; then
        echo "${E}  Index for [${indexName}] already exists!  ${X}"
        return 2

    elif ! mkdir -p "$docsHome"; then
        echo "${E}  Unable to create docs home: ${docsHome}  ${X}"
        return 4
    fi

    myman_cfg "index.${indexName}.src" "$indexPath"

    myman_build "$indexName"

    return 0
}
export -f myman_init
