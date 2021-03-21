# bashInstaller
Generic script for installing my other bash scripts

## Usage
Add the following file to your app as `install.sh`
```
#!/bin/bash
curl https://raw.githubusercontent.com/stevenharradine/bashInstaller/master/installer.sh | bash -s program=qBash
```

### Arguments
 * `program` - (Required) the file name of what is being installed
 * `installPath` - where the script will install too
 * `skip-ownership-and-permissions` - skips changing the ownership and permissions of the file
 * `add-sh-file-extention` - add the standard ".sh" file extention to the scripts filename
