#!/usr/bin/env sh
if [ -z "$STUDIO_BUILD_COMMAND" ]; then # if STUDIO_BUILD_COMMAND is not defined, initialize it
	export STUDIO_BUILD_COMMAND="mvn clean package"
fi

DEBUG_LINE="-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=5005"
STUDIO_EXEC_NAME=AnypointStudio

function __edit {
	if [ "$1" = "" ]; then
  		exec $EDITOR .
	else
  		exec $EDITOR $1
	fi
}

function __studioproductpathos {
	local PATH_TO_PRODUCT_BASE=org.mule.tooling.products/org.mule.tooling.studio.product/target/products/studio.product

	local PATH_TO_PRODUCT_MAC=$PATH_TO_PRODUCT_BASE/macosx/cocoa/x86_64/AnypointStudio.app

	local PATH_TO_PRODUCT_LINUX_BASE=$PATH_TO_PRODUCT_BASE/linux/gtk
	local PATH_TO_PRODUCT_LINUX_64=$PATH_TO_PRODUCT_LINUX_BASE/x86_64/AnypointStudio
	local PATH_TO_PRODUCT_LINUX_32=$PATH_TO_PRODUCT_LINUX_BASE/x86/AnypointStudio

	local PATH_TO_PRODUCT_WINDOWS_BASE=$PATH_TO_PRODUCT_BASE/win32/win32
	local PATH_TO_PRODUCT_WINDOWS_64=$PATH_TO_PRODUCT_WINDOWS_BASE/x86_64/AnypointStudio
	local PATH_TO_PRODUCT_WINDOWS_32=$PATH_TO_PRODUCT_WINDOWS_BASE/x86/AnypointStudio

	if [[ "$OSTYPE" == "darwin"* ]]; then echo $PATH_TO_PRODUCT_MAC
	elif [[ "$OSTYPE" == "msys" ||  "$OSTYPE" == "cygwin" ]]; then
	       if [[ `uname -m` == "x86_64" ]]; then echo $PATH_TO_PRODUCT_WINDOWS_64
	       else echo $PATH_TO_PRODUCT_WINDOWS_32
	       fi
	# ti's a Linux
        elif [[ `uname -m` == "x86_64" ]]; then echo $PATH_TO_PRODUCT_LINUX_64
	else echo $PATH_TO_PRODUCT_LINUX_32
	fi
}

function __studiorepopathfromcontext {
	if [ -z $1 ]; then return 1; else
		local original_dir=$PWD
		cd "$1"
		if [[ `git config remote.origin.url` =~ mulesoft/Mule-Tooling ]]; then
			local __path=`git rev-parse --show-toplevel`
		else
			local __path="Error trying to find path from this context"
		fi
		cd "$original_dir"
	fi
	echo "$__path"
}

function __studioproductpath {
	if [ -z $1 ]; then REPO_LOCATION=$(__studiorepopathfromcontext `pwd`); else REPO_LOCATION=$WS_HOME/$1; fi
	echo $REPO_LOCATION/$(__studioproductpathos)
}

function __studioproductini {
	local PRODUCT_PATH=$(__studioproductpath $1)
	if [[ $OSTYPE == "darwin"* ]]; then echo $PRODUCT_PATH/$STUDIO_EXEC_NAME.app/Contents/MacOS/$STUDIO_EXEC_NAME.ini
	else echo $PRODUCT_PATH/$STUDIO_EXEC_NAME.ini
	fi
}

function editstudioproductini {
	local ini_file=$(__studioproductini $1)
	__edit $ini_file
}

function openstudio {
	local PRODUCT_PATH=$(__studioproductpath $1)

	if [[ $OSTYPE == "darwin"* ]]; then open $PRODUCT_PATH
	elif [[ "$OSTYPE" == "msys" ||  "$OSTYPE" == "cygwin" ]]; then $PRODUCT_PATH/$STUDIO_EXEC_NAME.exe
	# ti's a Linux
	else $PRODUCT_PATH/$STUDIO_EXEC_NAME
	fi
}

function setdebugforstudio {
	local STUDIO_INI=$(__studioproductini $1)
	echo $DEBUG_LINE >> $STUDIO_INI
}

function unsetdebugforstudio {
	local STUDIO_INI=$(__studioproductini $1)
	sed -i.ini "/^$DEBUG_LINE/d" $STUDIO_INI
}

function buildstudio {
	local original_dir="$PWD"
	local repo_location=$(__studiorepopathfromcontext $PWD)
	cd $repo_location
	eval "$STUDIO_BUILD_COMMAND"
	local build_code=$?
	if [[ $build_code = 0 ]]; then
		echo $build_code
		command -v osascript >/dev/null 2>&1 && osascript -e 'display notification "Studio has finished building :)" with title "Built finished!" sound name "default"'
	fi
	cd $original_dir
	return build_code
}
