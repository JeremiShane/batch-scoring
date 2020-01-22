#!/bin/bash
# Usage: invoked my "make offlinebundle_dockerized"
# it is meant to run inside a docker container where it sets up the environment
# it then calls the "make offlinebundle" build command
set -e

REPO_BASE="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. && pwd )"
cd $REPO_BASE
# venv as a module requires python3.5+
PYTHON=`which python3.5 || which python3`

rm -rf /tmp/TEMPVENV ./dist/batch_scoring_offlinebundle
$PYTHON -m venv /tmp/TEMPVENV
. /tmp/TEMPVENV/bin/activate

mkdir -p dist/batch_scoring_offlinebundle/required_packages dist/batch_scoring_offlinebundle/helper_packages
cp OFFLINEBUNDLE_INSTALL_README.txt dist/batch_scoring_offlinebundle/
wget https://bootstrap.pypa.io/get-pip.py
#  add documentation to zip
mv get-pip.py dist/batch_scoring_offlinebundle/

pip install -U pip setuptools
python setup.py sdist
VERSION=$($PYTHON -c 'from datarobot_batch_scoring.__init__ import __version__ as v ; print(v)')
pip download --dest=dist/batch_scoring_offlinebundle/helper_packages --no-cache-dir --only-binary :all: \
				--implementation=py --abi=none --platform=any \
				pip setuptools virtualenv wheel appdirs \
				pyparsing six packaging
pip download --dest=dist/batch_scoring_offlinebundle/required_packages --no-cache-dir --no-binary :all: \
				dist/datarobot_batch_scoring-"${VERSION}".tar.gz
rm dist/datarobot_batch_scoring-"${VERSION}".tar.gz
cd ./dist
zip -r -0 datarobot_batch_scoring_"${VERSION}"_offlinebundle.zip batch_scoring_offlinebundle
tar -cf datarobot_batch_scoring_"${VERSION}"_offlinebundle.tar batch_scoring_offlinebundle
