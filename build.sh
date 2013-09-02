#!/bin/bash

# set your configuration here
configuration=Debug
workspace=CommentStream.xcworkspace
scheme=CommentStream
target=CommentStream
sdk=iphonesimulator

# get directory of this script
SOURCE_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# write a Python cfg file
cat >"$SOURCE_ROOT/.ycm_extra_conf.cfg" <<EOF
[Path Variables]

target=${target}
configuration=${configuration}
EOF

# perform Xcode build
xcodebuild -configuration "$configuration" -workspace "$workspace" -scheme "$scheme" -sdk "$sdk" -derivedDataPath "$SOURCE_ROOT/DerivedData" clean build 
