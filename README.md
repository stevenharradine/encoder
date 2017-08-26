# bashInstaller
Generic script for installing my other bash scripts

## Usage
Add the following file to your app as `install.sh`
```
installPath=/usr/local/bin
program=qBash

wget -O installer.sh https://raw.githubusercontent.com/stevenharradine/bashInstaller/master/installer.sh
source installer.sh
rm installer.sh
```

### Configure
 * `installPath` - where the script will install too
 * `program` - the file name of what is being installed
