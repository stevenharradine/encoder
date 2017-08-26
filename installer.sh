#!/bin/bash
# (c) 2017 Steven Harradine
if [ "$EUID" -ne 0 ]; then
	echo "Please run as root"
else
	echo -n "Installing . "
	cp $program.sh $installPath/$program
	chown root:root $installPath/$program
	chmod 755 $installPath/$program
	echo "Done"
fi
