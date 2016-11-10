#!/bin/bash

# version comparator function by Dennis Williamson @ http://stackoverflow.com/questions/4023830/how-compare-two-strings-in-dot-separated-version-format-in-bash
vercomp() {
	if [[ $1 == $2 ]]
	then
		return 0
	fi
	local IFS=.
	local i ver1=($1) ver2=($2)
	# fill empty fields in ver1 with zeros
	for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
	do
		ver1[i]=0
	done
	for ((i=0; i<${#ver1[@]}; i++))
	do
		if [[ -z ${ver2[i]} ]]
		then
			# fill empty fields in ver2 with zeros
			ver2[i]=0
		fi
		if ((10#${ver1[i]} > 10#${ver2[i]}))
		then
			return 1
		fi
		if ((10#${ver1[i]} < 10#${ver2[i]}))
		then
			return 2
		fi
	done
	return 0
}

do_upstall() {
	local REPO_LOCATION=git@github.com:moliva/studio-utils.git
	local INSTALLATION_DIR=~/.studio-utils
	local STUDIO_UTILS_SH=studio.sh

	git clone $REPO_LOCATION $INSTALLATION_DIR
	echo "source $INSTALLATION_DIR/$STUDIO_UTILS_SH" >> ~/.bashrc
}

upstall() {
	local TO_BE_INSTALLED_STUDIO_UTILS_VERSION=1.0.0

	if [ -z "$CURRENT_STUDIO_UTILS_VERSION" ]; then
		echo "Brand new Studio Utils installation"
		do_upstall
	else
		vercomp "$CURRENT_STUDIO_UTILS_VERSION" "$TO_BE_INSTALLED_STUDIO_UTILS_VERSION"

		case $? in
			0) echo "Studio Utils are already installed and up to date, no need for installation!";;
			1) echo "A greater version of Studio Utils is already installed, no installation will be run!";;
			2) echo "Updating Studio Utils from version $CURRENT_STUDIO_UTILS_VERSION to $TO_BE_INSTALLED_STUDIO_UTILS_VERSION"
				do_upstall;;
		esac
	fi

	if [ $? == 0 ]; then
		# update the current version
		export CURRENT_STUDIO_UTILS_VERSION=$TO_BE_INSTALLED_STUDIO_UTILS_VERSION
	fi
}

upstall
