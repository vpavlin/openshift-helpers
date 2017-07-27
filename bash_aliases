# Go through all specified pods and cat a file
# oc-cat FILE POD_NAME [POD_NAME...]
function oc-cat() {
    f=$1
    shift
    for i in $@; do
        echo "================= $i - $f ===================="
        oc exec -it $i -- cat $f
    done
}

# Go through all specified pods and follow a tail of the speicified file
# oc-tail FILE POD_NAME [POD_NAME...]
function oc-tail() {
    f=$1
    shift
    for i in $@; do
        echo "================= $i - $f ===================="
        oc exec -it $i -- tail -f $f
    done
}

# List and filter all contexts for a given expression. 
# It prints out the name of context as it is supposed to be used in
# oc --context ...
# or in ocuc below
# occ my_namespace_in_os
function occ() {
    CONTEXT=""
    if [ -n $1 ]; then
        CONTEXT=$1
    fi

    oc config get-contexts | grep "$CONTEXT" | sed 's/[* ]*//' | awk '{print $1}'
}

# Switch to a given context
# ocuc CONTEXT
function ocuc() {
    if [ $# -lt 1 ]; then
        echo "Missing argument CONTEXT"
        return 1
    fi

    oc config use-context $1
}

# Wrapper function for oc command to 
# a) block oc apply from uploading to a context not matching a git repo and directory
#       i.e. Given a repo name (dtsd/saas-crypt) and a cluster identifier (rh-idev, dsaas) this function will check 
#       user is in the given repository and context matches the cluster. If true, it will check the PATH given in 
#       oc apply -f PATH against OpenShift project name and block the command if those two do not match. I'll return
#       the command as expected otherwise
# b) add an oc subcommand for decoding secrets
#       oc decode FILE
function oc() {
    OPENSHIFT="rh-idev|dsaas"
    REPO=dtsd/saas-crypt
    CMD=echo
    [ -x /usr/bin/oc ] && CMD=/usr/bin/oc
    [ -x ~/bin/oc ] && CMD=~/bin/oc
    if [ "$1" == "apply" ] && [[ "$(git config --get remote.origin.url)" =~ $REPO ]] && oc whoami -c | grep -q -E "$OPENSHIFT"; then
        next=false
        path=""
        for p in `echo $@`; do
            if [ $p == "-f" ]; then
                next=true
                continue
            fi
            if $next; then
                path=$p
                break
            fi
        done
        context=$(oc whoami -c)
        if echo $path | grep -q ${context%%/*}; then
            $CMD $@
        else
            echo "Cannot apply from ${path%%/*} to ${context%%/*}"
        fi
    elif [ "$1" == "decode" ]; then
        decode-secret.py $2
    else
        $CMD $@
    fi
}
