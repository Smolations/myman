## /* @function
 #  @usage myman_cfg [-d|-r]
 #  @usage myman_cfg [-r] <key>
 #  @usage myman_cfg <key> <value>
 #
 #  @output true
 #
 #  @description
 #  This script serves as proxy for setting myman's cfg. Since __cfg currently
 #  relies on the current working directory in order to use its cfg, it is
 #  necessary to switch to a valid directory before issuing commands. See the
 #  documentation for __cfg for more information.
 #  description@
 #
 #  @dependencies
 #  `less`
 #  `egrep`
 #  lib/__cfg/functions/__cfg.sh
 #  dependencies@
 #
 #  @file functions/myman_cfg.sh
 ## */

function myman_cfg {
    local in_myman_path
    [ "$(pwd)" == "${myman_path}" ] && in_myman_path=true || in_myman_path=false

    ! $in_myman_path && pushd "${myman_path}" &> /dev/null
    __cfg $@
    ! $in_myman_path && popd &> /dev/null
}
export -f myman_cfg
