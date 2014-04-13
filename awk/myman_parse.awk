BEGIN {
    # all tokens/tags should be placed here for easy modification
    commentStart = "^[[:blank:]]*##[[:blank:]]*\\/\\*"

    tagStart = "^@[[:alnum:]]+$"
    tagStop = "^[[:alnum:]]+@"

    tagColor = "\033[36m"   #cyan
    tagX = "\033[0;20;39m"  #reset styles

    name = ""
}
# { print $1 "|" $2 "|" $3 "|" $4 "|" $5 }

# the opening tag: ## /*
$0 ~ commentStart {
    # print type descriptor
    dMatch = match( $0, /@[[:alnum:]]+/ )
    print "type:" substr( $0, RSTART + 1, RLENGTH - 1 )
}

$2 ~ tagStart {
    # this substitution carries over to any subsequent matches
    gsub( $2, tagColor $2 tagX, $0 )

    if ( length(name) == 0 && match($2, "@usage") ) {
        name = $3
        print "name:" $3
    }
}

$2 !~ tagStop {
    if ( match($1, /^#$/) ) {
        match ( $0, "#" )
        print substr( $0, RSTART + 1 )
    }
}
