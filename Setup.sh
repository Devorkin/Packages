#! /bin/bash

# Load dependecy script
. OS_version.sh

# Script variables
set -o nounset
echo $(tput sgr0)
Args=("$@")
OSname=''
OStype=''
OSversion=''

# Output templates:
description_msg() {
	echo -e "$(tput setaf 10)--> $*$(tput sgr0)"
}
error_msg() {
	echo -e "$(tput setaf 1)(X) --> $*$(tput sgr0)"
}
notification_msg() {
	echo -e "$(tput setaf 3)##\n## $*\n##\n$(tput sgr0)"
}
output_msg() {
	echo -e "$(tput setaf 2)--> $*$(tput sgr0)"
}
query_msg() {
	echo -e "$(tput setaf 9)--> $*$(tput sgr0)"
}
warning_msg() {
	echo -e "$(tput setaf 3)(!) --> $*$(tput sgr0)"
}
function echodo {
	output_msg "$@"
	"$@"
}

function Brew {
    which brew > /dev/null
	if [[ $? != 0 ]]; then 
		output_msg "Attempting to install Brew..."
		yes '' | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
		export PATH=$PATH:/usr/local/bin:/usr/local/sbin
		echodo brew update > /dev/null
		if [[ "`brew analytics`" != 'Analytics is disabled.' ]]; then 
			echodo brew analytics off
		fi
    else
        output_msg "Brew has been detected, will make sure it is working well and updated..."
        echodo brew doctor
        echodo brew analytics off
	fi
}

function Brew_Cask {
    for CASK in alacritty android-file-transfer apache-directory-studio dashlane disk-inventory-x docker dropbox firefox google-chrome google-backup-and-sync iterm2 keepassx kodi microsoft-office quicklook-json sequel-pro slack sourcetree spotify telegram the-unarchiver whatsapp vagrant visual-studio-code virtualbox virtualbox-extension-pack vlc wireshark zenmap; do
        echodo brew install --cask ${CASK}
    done
}

function Brew_Packages {
    for PACKAGE in autoconf awscli automake berkeley-db@4 brightness dockutil fontconfig git glances glib gnu-sed grc gtk+ htop iperf java jq kubernetes-cli mtr neofetch nethogs node nvim openssl pkg-config powershell python speedtest-cli ssh-copy-id svn telnet ubersicht vault virtualbox watch wget wireshark zsh; do
        #python@2
        echodo brew install $PACKAGE
	done
}

function Node_modules {
    which npm > /dev/null
    if [ $? == 0 ] ; then
        for MODULE in gtop; do
            npm list -g | grep ${MODULE} > /dev/null
            if [ $? != "0" ]; then
                output_msg "Installing the Node.js module: ${MODULE}..."
                echodo npm install ${MODULE} -g > /dev/null
            fi
        done
    fi
}

function OS_Setup {
    output_msg "Performing Operating system update..."
    echodo sudo softwareupdate -i -a
}

# Brew does not support anymore Python2
# function Python_modules {
#     which pip2 > /dev/null
#     if [ $? == 0 ] ; then
#         for MODULE in clint jira pylint requests; do
#             pip2 list --format=columns | tr -s ' ' | grep -i "^$MODULE " > /dev/null
#             if [ $? != "0" ]; then
#                 output_msg "Installing the Python module: $MODULE..."
#                 sudo pip2 install $MODULE > /dev/null
#             fi
#         done
#     fi
# }

function Sudoer {
    sudo -v
    # Keep-alive: update existing `sudo` time stamp until `$0` has finished
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
}

function Vagrant {
    which vagrant > /dev/null
    if [ $? == 0 ]; then
        for PLUGIN in "vagrant-hosts vagrant-vbguest"; do
            echodo vagrant plugin install $PLUGIN
        done
    fi
}

function VisualStudioCode {
    if [[ -f /Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code ]]; then
        for EXTENSION in bbenoist.vagrant DavidAnson.vscode-markdownlint jpogran.puppet-vscode liximomo.sftp ms-azuretools.vscode-docker ms-mssql.mssql ms-python.python ms-vscode.powershell vscode-icons-team.vscode-icons; do
            echodo /Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code --install-extension ${EXTENSION}
        done
    fi
}


### Main ###
if [ $EUID == 0 ]; then
	error_msg "### This script must run WITHOUT Root privileges!"
	exit 101
fi

OS_type
OS_version

output_msg 'Detected:'
description_msg "\t OS:\t\t\t${OStype}"
if [[ ! -z ${OSname} ]]; then
    description_msg "\t OS name:\t\t${OSname}"
fi
description_msg "\t OS version:\t\t${OSversion}"

if [[ ${OStype} == "OSX" ]]; then
    Sudoer
    Brew
    Brew_Packages
    Brew_Cask
    Node_modules
    Python_modules
    Vagrant
    VisualStudioCode
    # Repeating, to fix broken packages
    Brew_Cask
    Brew_Packages
    OS_Setup
fi

exit 0