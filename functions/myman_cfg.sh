function myman_cfg {
    [ "$(pwd)" == "${myman_path}" ] && in_myman_path=true || in_myman_path=false

    ! $in_myman_path && pushd "${myman_path}" &> /dev/null
    __cfg $@
    ! $in_myman_path && popd &> /dev/null
}
export -f myman_cfg
