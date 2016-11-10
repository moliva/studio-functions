#!/usr/bin/env sh

# initialize env vars
if [ -z "$STUDIO_BUILD_COMMAND" ]; then # if STUDIO_BUILD_COMMAND is not defined, initialize it
	export STUDIO_BUILD_COMMAND="mvn clean package"
fi

if [ -z "$EDITOR" ]; then
	export EDITOR="vim"
fi

if [ -z "$STUDIO_BUILD_OPTS" ]; then
	export STUDIO_BUILD_OPTS=
fi

if [ -z "$DEBUG_LINE" ]; then
	export DEBUG_LINE="-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=5005"
fi

STUDIO_EXEC_NAME=AnypointStudio

function __edit {
	if [ "$1" = "" ]; then
  		exec $EDITOR .
	else
  		exec $EDITOR $1
	fi
}

function __studioproductpathos {
	local path_to_product_base=org.mule.tooling.products/org.mule.tooling.studio.product/target/products/studio.product

	local path_to_product_mac=$path_to_product_base/macosx/cocoa/x86_64/AnypointStudio.app

	local path_to_product_linux_base=$path_to_product_base/linux/gtk
	local path_to_product_linux_64=$path_to_product_linux_base/x86_64/AnypointStudio
	local path_to_product_linux_32=$path_to_product_linux_base/x86/AnypointStudio

	local path_to_product_windows_base=$path_to_product_base/win32/win32
	local path_to_product_windows_64=$path_to_product_windows_base/x86_64/AnypointStudio
	local path_to_product_windows_32=$path_to_product_windows_base/x86/AnypointStudio

	if [[ "$OSTYPE" == "darwin"* ]]; then echo $path_to_product_mac
	elif [[ "$OSTYPE" == "msys" ||  "$OSTYPE" == "cygwin" ]]; then # windows terminal
	       if [[ `uname -m` == "x86_64" ]]; then echo $path_to_product_windows_64
	       else echo $path_to_product_windows_32
	       fi
	# ti's a Linux
        elif [[ `uname -m` == "x86_64" ]]; then echo $path_to_product_linux_64
	else echo $path_to_product_linux_32
	fi
}

function __studiorepopathfromcontext {
	if [ -z $1 ]; then return 1; else
		local original_dir=$PWD
		cd "$1"
		if [[ `git config remote.origin.url` =~ mulesoft/Mule-Tooling ]]; then
			echo `git rev-parse --show-toplevel`
			local return_code=0
		else
			local return_code=1
		fi
		cd "$original_dir"
	fi
	return $return_code
}

function __studioproductpath {
	if [ -z $1 ]; then
		local repo_location=$(__studiorepopathfromcontext `pwd`)
	else
		local repo_location=$WS_HOME/$1
	fi

	echo $repo_location/$(__studioproductpathos)
}

function __studioproductini {
	local product_path=$(__studioproductpath $1)
	if [ -n $product_path ]; then
		if [[ $OSTYPE == "darwin"* ]]; then echo $product_path/$STUDIO_EXEC_NAME.app/Contents/MacOS/$STUDIO_EXEC_NAME.ini
		else echo $product_path/$STUDIO_EXEC_NAME.ini
		fi
	fi
}

# ----------------------------------------------
# ------------ Public functions ------------
# ----------------------------------------------

function editstudioproductini {
	local studio_ini=$(__studioproductini $1)
	if [ -n $studio_ini ]; then
		__edit $studio_ini
	else echo "Could not find the INI file in the current repo"
	fi
}

function openstudio {
	local product_path=$(__studioproductpath $1)

	if [ -n $product_path ]; then
		if [[ $OSTYPE == "darwin"* ]]; then open $product_path
		elif [[ "$OSTYPE" == "msys" ||  "$OSTYPE" == "cygwin" ]]; then $product_path/$STUDIO_EXEC_NAME.exe
		# ti's a Linux
		else $product_path/$STUDIO_EXEC_NAME
		fi
	else echo "Could not find the repo location"
	fi
}

function setdebugforstudio {
	local studio_ini=$(__studioproductini $1)
	echo $DEBUG_LINE >> $studio_ini
}

function unsetdebugforstudio {
	local studio_ini=$(__studioproductini $1)
	sed -i.ini "/^$DEBUG_LINE/d" $studio_ini
}

function buildstudio {
	local original_dir="$PWD"
	local studio_build_parameters=$*
	local repo_location=$(__studiorepopathfromcontext $PWD)
	if [ -n "$repo_location" ]; then
		cd $repo_location
		eval "$STUDIO_BUILD_COMMAND $STUDIO_BUILD_OPTS $studio_build_parameters"
		local build_code=$?
		if [[ $build_code = 0 ]]; then
			command -v osascript >/dev/null 2>&1 && osascript -e 'display notification "Studio has finished building :)" with title "Build finished!" sound name "default"'
		else
			command -v osascript >/dev/null 2>&1 && osascript -e 'display notification "Studio has finished unsuccessfully :(" with title "Build failed!" sound name "Basso"'
		fi
		cd $original_dir
		return $build_code
	else echo "Error trying to find the repo location"; return 1
	fi
}

function updatestudioutils {
	sh -c "$(curl -fsSL https://raw.github.com/moliva/studio-utils/master/scripts/installation.sh)"
	source ~/.studio-utils/studio.sh
}
