OpenShift Helpers

To use this, add content of `bash_aliases` to your `.bashrc` or `bash_aliases` file. 

## Contexts

I have 285 contexts in my kube config and it's a mess. I could clean it up, but I still use multiple projects across many clusters so I needed something that will make working with contexts more resonable.

`occ` let's you grep through your contexts.

```
$ occ myapp
myapp/10-3-10-63-xip-io:8443/developer
myapp-fabric8/10-3-10-63-xip-io:8443/developer
```

`ocuc` let's you switch contexts

```
$ ocuc myapp/10-3-10-63-xip-io:8443/developer
Switched to context "myapp/10-3-10-63-xip-io:8443/developer".
```

I also updated my prompt with showing the context I am using

```
[vpavlin@unused-4-251 ~/devel/upstream/openshift-helpers(master) (myapp/10-3-10-63-xip-io)]
```

## Uploading to wrong projects

I work in a team which manages deployments for multiple OpenShift clusters. Deployments of DC and SVC is automated, but we still haven't figured out how to keep secrets managed, private and their deployment automated. As secrets do not change often, it's not a big deal, but problem is when you are pushing new secrets or updating old, it is stressful to make sure you are pushing right secret in the right project (10+ secrets and configmaps for each of 10+ projects across 2 clusters...). So I wrapped my `oc` command with a little function which you can find in `bash_aliases` file.

It "simply" checks

* Github repo
* Directory in that repo
* Cluster
* Project

and stops you if things do not match. In other words:

1. Check I am in the repo with secrets and I am logged into one of clusters I care about, if not proceed with `oc apply`
2. Take project name from current context and match it against path given in `oc apply -f PATH`. If they match, proceed with `oc apply`
3. As they did not match, print error message

The script is a hack and it's not smar enough so it will fail in cases where it should not, but so far it blocked all my attempts to do something wrong. In this case, I am in for some false positives rather than false negatives:).

If you want to use the `oc apply` check, please change the ENV vars in the function

## Decoding secrets

As explained above, I work with OpenShift secrets often and it's pain to decode values manually using `base64 -d` command one by one. For that, I wrote a simple python script to decode OpenShift secret and added a few lines in my `oc` function wrapper to add a new subcommand - `oc decode`.

```
$ oc decode some_secret.yaml 
Name: name_of_secret
===========
postgres.port = 5432
postgres.host = some_url
postgres.database = postgres
postgres.user = dbadmin
postgres.password = secret_pass
```

To have `oc decode` working, copy `decode-secret.py` to a location in `$PATH` and make it executable (`chmod +x decode-secret.py`)