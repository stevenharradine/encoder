#!/bin/bash
# (c) 2021 Steven Harradine
installDir=/usr/local/bin
githubUser=stevenharradine
gitBranch=master
apply_ownership_and_permissions=true
add_sh_file_extention=false

if [ "$EUID" -ne 0 ]; then
        echo "Please run as root"
else
        for arg in "$@"; do
                key=`echo "$arg" | awk -F "=" '{print $1}'`
                value=`echo "$arg" | awk -F "=" '{print $2}'`

                if [[ $key == "installDir" ]]; then
                        installDir=$value
                elif [[ $key == "program" ]]; then
                        program=$value
                elif [[ $key == "githubUser" ]]; then
                        githubUser=$value
                elif [[ $key == "gitBranch" ]]; then
                        gitBranch=$value
                elif [[ $key == "skip-ownership-and-permissions" ]]; then
                        apply_ownership_and_permissions=false
                elif [[ $key == "add-sh-file-extention" ]]; then
                        add_sh_file_extention=true
                fi
        done

        if [[ $program == "" ]]; then
                echo "You must define a program when calling the installer"
        else
                echo -n "Installing . "

                installPath=$installDir/$program
                if [[ $add_sh_file_extention == true ]]; then
                        echo -n "add-sh-file-extention . "
                        installPath=$installPath.sh
                fi

                wget --quiet --output-document $installPath https://raw.githubusercontent.com/$githubUser/$program/$gitBranch/$program.sh

                if [[ $apply_ownership_and_permissions == true ]]; then
                        chown root:root $installPath
                        chmod 755 $installPath
                else
                        echo -n "skip-ownership-and-permissions . "
                fi
                echo "Done"
        fi
fi
