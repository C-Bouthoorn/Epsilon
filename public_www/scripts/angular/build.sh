#!/bin/bash

# Colour codes
red="\e[1;31m"
green="\e[1;32m"
blue="\e[1;34m"
none="\e[0m"

# Project root
root="$(pwd)"

# Make sure shasums folder exist
mkdir -p "$root/shasums"

# Print color
color() {
	echo -ne "$1";
}

# Check error code
check() {
	ec=$1

	if [ $ec = 0 ]; then
		color $green
		echo -e "\t OK"
	else
		color $red
		echo -e "\t Failed [$ec]"
	fi

	color $none
}

# Format time
mytime() {
	echo -n "$(date +"%H:%M:%S")"
}

# Check if shasum has changed
haschanged() {
	prefix=$1
	file=$2

	shafile="$root/shasums/$file.sum"

	oldsum=""
	if [ -f "$shafile" ]; then
		oldsum=$(cat "$shafile")
	fi

	newsum=$(sha256sum "$file")

	if [ "$oldsum" = "$newsum" ]; then
		return 1
	else
		echo "$newsum" > "$shafile"
		return 0
	fi
}

# Build file
build() {
	prefix=$1

  # Build coffeescript
	for f in *.coffee; do
		# Check if file exists and is readable
		if [ -f $f ]; then
			# Check for changes
			haschanged "$prefix" "$f"
			if [ $? = 0 ]; then
				echo -n "[$(mytime)] Building $f"
				coffee -cb "$f"
				check $?
			fi
		fi
	done
}

# Check arguments
force=false
if [ "$1" = "force" ] || [ "$2" = "force" ]; then
	force=true
fi


if [ "$1" = "server" ]; then
	color $blue
	echo "Build server started!"
	color $none

	while [ true ]; do

		./build.sh "$force"

		sleep 1
	done
fi


# Build root folder
build ""

# Build controllers folder
cd controllers
	build "controllers-"
	cd ..
