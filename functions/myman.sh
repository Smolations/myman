## /* @function
 #  @usage myman <[options] | [keyword]>
 #
 #  @description
 #  MyMan (My Manual) is to your scripts as the Man Pages are to Unix commands.
 #  The information for `myman` entries can be as extensive as the user wishes. The
 #  `myman` essentially looks for files which contain comments matching an expected
 #  syntax. It then parses those comment blocks, generating the documentation in the
 #  ~/.myman folder. These blocks take the form:
 #
 #      ## /* @category (optional)
 #      #   @oneLineTag lorem ipsum
 #      #
 #      #   @tagBlock
 #      #   Lorem ipsum blah blah....
 #      #   tagBlock@
 #      ## */
 #
 #  where the start of the comment is two pound signs (#) followed by a forward
 #  slash and asterisk, and the closing of the comment is two pound signs followed
 #  by an asterisk and a forward slash. This syntax closesly resembles block-style
 #  comments in CSS and other web languages. Tag names begin with the "at" symbol (@)
 #  and are followed by one or more letters of the alphabet. Common tags used are:
 #
 #      @usage      << This tag MUST be on the very next line after the opening
 #                     double-hash.
 #      @output
 #      @exports
 #      @description
 #      @options
 #      @notes
 #      @examples
 #      @dependencies
 #      @returns
 #      @file
 #
 #  `myman` leverages the `less` program to enable pagination just like `man`. So,
 #  to exist the documentation, just press 'q'.
 #  description@
 #
 #  @options
 #  --build[=<index-name>]  If no value is passed, `myman` will build all of the
 #                          indexes it knows about. If an <index-name> is passed,
 #                          only build the <index-name> index.
 #  --list[=<index-name>]   If an <index-name> is passed, display all of the
 #                          commands for that index which have `myman` comments.
 #                          Otherwise, first show a list of the available indexes
 #                          to choose from.
 #  -h, --help              Same as `myman myman`.
 #  options@
 #
 #  @notes
 #  - The @usage tag MUST be included on the first line under the comment
 #  opening line (## /*) for the comments to be available via `myman`.
 #  - If an option is given, omit the keyword. Both should not be used
 #  simultaneously.
 #  notes@
 #
 #  @examples
 #  $ myman myCommand
 #  $ myman --help
 #  $ myman --list              # get a list of all indexes, then choose command
 #  $ myman --build=myproject   # only build documentation for the "myproject" index
 #  examples@
 #
 #  @dependencies
 #  functions/myman_build.sh
 #  functions/myman_list.sh
 #  functions/myman_parse.sh
 #  dependencies@
 #
 #  @file functions/myman.sh
 ## */

function myman {
    case $# in

        1)
            case "$1" in
                "--list" | "-h" | "--help")
                    myman_list;;

                "--list="*)
                    myman_list "${1:7}";;

                "--add")
                    myman_init;;

                "--refresh")
                    __source_all "${myman_path}/functions" && echo "OK";;

                "--build")
                    myman_build;;

                "--build="*)
                    myman_build "${1:8}";;

                *)
                    myman_parse "$1";;
            esac
            ;;

        0)
            myman_parse "myman";;

    esac
}
export -f myman
