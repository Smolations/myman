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
 #      @usage      << This tag MUST be on line 2 (or 3 if there's a shebang) after
 #                     the opening double-hash.
 #      @output
 #      @exports
 #      @description
 #      @options
 #      @notes
 #      @examples
 #      @dependencies
 #      @returns
 #      @file
 #  description@
 #
 #  @options
 #  --build[=main|user]     Build the files which are used for outputting comments
 #                          in an easy-to-read format. Also build command index
 #                          files. If "user" is specified, only build the user
 #                          index/help.
 #  --list[=user|all),      Show a list of all the files which contain `myman` comments
 #                          and are accessible using the `myman` command. If "user" is
 #                          specified, only show commands that have been indexed from
 #                          paths set in the $gitscripts_paths_user variable. If "all" is
 #                          specified, show both user AND GitScripts native command lists.
 #  -h, --help              Same as --list.
 #  options@
 #
 #  @notes
 #  - The @usage tag MUST be included on the first line (under ## /*) for the
 #  comments to be available in `myman`!
 #  - If an option is given, omit the keyword. Both should not be used
 #  simultaneously.
 #  notes@
 #
 #  @examples
 #  1) myman phone
 #  2) myman --help
 #  3) myman --list=all    # get a list of all commands
 #  examples@
 #
 #  @dependencies
 #  myman_build.sh
 #  myman_list.sh
 #  myman_parse.sh
 #  dependencies@
 #
 #  @file myman.sh
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
