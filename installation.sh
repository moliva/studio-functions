#!/bin/bash

local REPO_LOCATION=git@github.com:moliva/studio-utils.git
local INSTALLATION_DIR=~/.studio-utils
local STUDIO_UTILS_SH=studio.sh

git clone $REPO_LOCATION $INSTALLATION_DIR

echo "source $INSTALLATION_DIR/$STUDIO_UTILS_SH" >> ~/.bashrc
