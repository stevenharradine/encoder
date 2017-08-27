#!/bin/bash
# (c) 2017 Steven Harradine
installPath=/usr/local/bin

if [ "$EUID" -ne 0 ]; then
	echo "Please run as root"
else
	for arg in "$@"; do
		key=`echo "$arg" | awk -F "=" '{print $1}'`
		value=`echo "$arg" | awk -F "=" '{print $2}'`

		if [[ $key == installPath ]]; then
			installPath=$value
		elif [[ $key == program ]]; then
			program=$value
		fi
	done

	if [[ $program == "" ]]; then
		echo "You must define a program when calling the installer"
	else
		echo -n "Installing . "
		cp $program.sh $installPath/$program
		chown root:root $installPath/$program
		chmod 755 $installPath/$program
		echo "Done"
	fi
fi
