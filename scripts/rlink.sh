#!/bin/bash

# rlink is useful when you are working in packages used in other packages/apps. Normally you
# would use yarn link but it can cause problems since node_modules are resolved inside the
# linked directory instead of the host directory. Here, the "link" is done the hard way with
# nodemon and rsync, ensuring that the node_modules/<package> corresponds to the linked package.
# Location of the linked packages is found by using the directory where yarn stores its symbolic
# links.
#
# ## Installation
# 
# Assuming ~/bin is in your PATH
# $ wget https://gist.githubusercontent.com/ptbrowne/add609bdcf4396d32072acc4674fff23/raw -O ~/bin/rlink
# $ chmod +x ~/bin/rlink
# 
# ## Usage
# 
# `rlink cozy-client`


realpath=$(which realpath)
if [[ $realpath == "" ]]; then
    realpath=$(which grealpath)
fi
if [[ $realpath == "" ]]; then
    echo "You must have realpath (or grealpath) installed. `brew install coreutils` on mac osx."
    exit 1
fi

which nodemon > /dev/null
if [[ $? != 0 ]]; then
    echo "You must have nodemon installed globally"
    exit 1
fi

set -e

package=$1

if [[ $package == "" ]]; then
    echo "Usage: rlink <package>"
    exit 1
fi

set -u

package_link_dir=$($realpath ~/.config/yarn/link/$package)


if [[ -e $package_link_dir ]]; then
    echo "$package is available in yarn links, resolved path is $package_link_dir"
else
    echo "$package is not available in yarn links, please \`yarn link\` there first."
    exit 1
fi

package_node_module_dir=$(pwd)/node_modules/$package

if [[ -e $package_node_module_dir ]]; then
    echo "$package is installed node_modules, resolved path is $package_node_module_dir"
else
    echo "$package is not installed node_modules. Bailing out, please install the package first."
    exit 1
fi

extensions="js,json,md,jsx,kt,java,m,mm,h,swift"

echo "Will monitor extensions $extensions"
cmd="rsync -aP $package_link_dir/ --exclude .git --exclude node_modules $package_node_module_dir/"

nodemon -w $package_link_dir -x "$cmd" -e $extensions
