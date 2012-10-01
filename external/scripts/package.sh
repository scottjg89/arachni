#!/usr/bin/env bash
#
# Copyright 2010-2012 Tasos Laskos <tasos.laskos@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

path_to_readlink_function=`dirname $0`"/lib/readlink_f.sh"
if [[ ! -e "$path_to_readlink_function" ]]; then
    echo "Could not find $path_to_readlink_function"
    exit
fi

source $path_to_readlink_function

cat<<EOF

            Arachni packager (experimental)
            ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 It packages a build directory, as generated by 'build.sh', into a self-extracting installer.

     by Tasos Laskos <tasos.laskos@gmail.com>
-------------------------------------------------------------------------

EOF

if [[ "$1" == '-h' ]] || [[ "$1" == '--help' ]]; then
    cat <<EOF
Usage: $0 [installer name] [build directory]

Installer name defaults to 'arachni-installer.sh'.
Build directory defaults to 'arachni'.

EOF
    exit
fi

echo
echo "# Checking for script dependencies"
echo '----------------------------------------'
deps="
    tar
    awk
    tail
    basename
    dirname
    readlink
"
for dep in $deps; do
    echo -n "  * $dep"
    if [[ ! `which "$dep"` ]]; then
        echo " -- FAIL"
        fail=true
    else
        echo " -- OK"
    fi
done

if [[ $fail ]]; then
    echo "Please install the missing dependencies and try again."
    exit 1
fi

if [[ ! -z "$1" ]]; then
    # root path
    instname="$1"
else
    # root path
    instname="arachni-installer.sh"
fi

if [[ ! -z "$2" ]]; then
    # root path
    instdir="$2"
else
    # root path
    instdir="arachni"
fi

echo

if [[ ! -s $instdir ]]; then
    echo "Could not find an installation under $instdir."
    exit 1
fi

root="$(dirname "$(readlink_f "${0}")")"
insttpl="$root/installer.sh.tpl"

if [[ ! -s $insttpl ]]; then
    echo "Could not find installer template: $insttpl."
    exit 1
fi


tmp_archive="$instname.tar.gz"

echo "# Generating installer"
echo '----------------------------------------'

echo "  * Cleaning"
rm -f $tmp_archive
rm -f $instname

echo "  * Copying installer template to '$instname'"

instdir_name=`basename $instdir`
cat $insttpl | sed "s/##PKG_NAME##/$instdir_name/g" > $instname
echo "`cat $root/lib/readlink_f.sh` `cat $instname`" > $instname


echo "  * Compressing build dir ($instdir)"
tar czf $tmp_archive -C `dirname $instdir` $instdir_name

echo "  * Appending the archive to the installer"
cat $tmp_archive >> $instname

echo "  * Setting installer permisions"
chmod +x $instname

echo
echo "Installer saved at '$instname'."
echo
