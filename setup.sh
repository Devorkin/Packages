#! /bin/bash

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

function Brew {
	xcode-select --install

    which brew > /dev/null
	if [[ $? != 0 ]]; then 
		output_msg "Attempting to install Brew..."
		curl -fsSL 'https://raw.githubusercontent.com/Homebrew/install/master/install' | ruby > /dev/null
		export PATH=$PATH:/usr/local/bin:/usr/local/sbin
		brew update > /dev/null
		if [[ "`brew analytics`" != 'Analytics is disabled.' ]]; then 
			brew analytics off
		fi
	fi
}

function Brew_Cask {
    for CASKROOM in "caskroom/cask"; do
        brew tap ${CASKROOM}
    done

    for CASK in android-file-transfer apache-directory-studio.rb dashlane disk-inventory-x docker dropbox firefox google-chrome google-backup-and-sync iterm2 java keepassx kodi microsoft-office quicklook-json sequel-pro slack sourcetree spotify telegram the-unarchiver whatsapp vagrant visual-studio-code virtualbox virtualbox-extension-pack vlc wireshark zenmap; do
        brew cask install ${CASK}
    done
}

function Brew_Packages {
    for PACKAGE in autoconf automake berkeley-db@4 brightness dockutil git glances glib gnu-sed grc gtk+ htop jq mtr nethogs node openssl pkg-config python ssh-copy-id telnet watch wget zsh; do
            brew install $PACKAGE
	done
}

function OS_type {
	# Recognize OS type:
	if [[ -f /etc/redhat-release ]]; then
        OStype="CentOS"
	elif [[ -f /usr/bin/lsb_release ]]; then
        OStype="Ubuntu"
	elif [[ -f /usr/bin/sw_vers ]]; then
		OStype="OSX"
	else
		error_msg "This script supports CentOS \ RHEL, OSX or Ubuntu OS ditributions!"
		exit 102
	fi
}

function Node_modules {
    which npm > /dev/null
    if [ $? == 0 ] ; then
        for MODULE in gtop; do
            npm list -g | grep ${MODULE} > /dev/null
            if [ $? != "0" ]; then
                output_msg "Installing the Node.js module: ${MODULE}..."
                npm install ${MODULE} -g > /dev/null
            fi
        done
    fi
}

function OS_Setup {
    output_msg "Performing Operating system update..."
    sudo softwareupdate -i -a
}

function OS_version {
    if [[ ${OStype} == "CentOS" ]]; then
        if [[ `cat /etc/redhat-release` == "CentOS Linux release 7."* ]]; then
			OSversion=7
		elif [[ `cat /etc/redhat-release` == "CentOS release 6."* ]]; then
			OSversion=6
        else
            error_msg "Your CentOS version is not supported yet!"
            exit 103
		fi
    elif [[ ${OStype} == "Ubuntu" ]]; then
        OSval=`/usr/bin/lsb_release -rs`
        case ${OSval} in
        14.04)
            OSname='Trusty Tahr'
            OSversion="14.04"
            ;;
        14.10)
            OSname='Utopic Unicorn'
            OSversion="14.10"
            ;;
        15.04)
            OSname='Vivid Vervet'
            OSversion="15.04"
            ;;
        15.10)
            OSname='Wily Werewolf'
            OSversion="15.10"
            ;;
        16.04)
            OSname='Xenial Xerus'
            OSversion="16.04"
            ;;
        16.10)
            OSname='Yakkety Yak'
            OSversion="16.10"
            ;;
        17.04)
            OSname='Zesty Zapus'
            OSversion="17.04"
            ;;
        17.10)
            OSname='Artful Aardvark'
            OSversion="17.10"
            ;;
        18.04)
            OSname='Bionic Beaver'
            OSversion="18.04"
            ;;
        18.10)
            OSname='Cosmic Cuttlefish'
            OSversion="18.10"
            ;;
        19.04)
            OSname='Disco Dingo'
            OSversion="19.04"
            ;;
        *)
            error_msg "Your Ubuntu version is not supported yet!"
            exit 104
            ;;
       esac
    elif [[ ${OStype} == "OSX" ]]; then
		OSval=`sw_vers -productVersion`
		case ${OSval} in
            10.6.*)
                OSname='Snow Leopard'
                OSversion="10.6"
                ;;
            10.7.*)
                OSname='Lion'
                OSversion="10.7"
                ;;
            10.8.*)
                OSname='Mountain Lion'
                OSversion="10.8"
                ;;
            10.9.*)
                OSname='Mavericks'
                OSversion="10.9"
                ;;
            10.10.*)
                OSname='Yosemite'
                OSversion="10.10"
                ;;
            10.11.*)
                OSname="El Capitan"
                OSversion="10.11"
                ;;
            10.12.*)
                OSname='High Sierra'
                OSversion="10.12"
                ;;
            10.13.*)
                OSname='High Sierra'
                OSversion="10.13"
                ;;
            10.14.*)
                OSname='Mojave'
                OSversion="10.14"
                ;;
            10.15.*)
                OSname='Catalina'
                OSversion="10.15"
                ;;
            10.14.*)
                OSname='Mojave'
                OSversion="10.14"
                ;;
            10.15 | 10.15.*)
                OSname='Catalina'
                OSversion="10.15"
                ;;
            *)
                error_msg "Your Mac OS version is not supported yet!"
                exit 105
        esac
    fi
}

function Python_modules {
    which pip2 > /dev/null
    if [ $? == 0 ] ; then
        for MODULE in clint jira pylint requests; do
            pip2 list --format=columns | tr -s ' ' | grep -i "^$MODULE " > /dev/null
            if [ $? != "0" ]; then
                output_msg "Installing the Python module: $MODULE..."
                sudo pip2 install $MODULE > /dev/null
            fi
        done
    fi
}

function Vagrant {
    which vagrant > /dev/null
    if [ $? == 0 ]; then
        for PLUGIN in "vagrant-hosts vagrant-vbguest"; do
            vagrant plugin install $PLUGIN
        done
    fi
}

function VirtualBox {
    if [ -d /Applications/VirtualBox.app ]; then
        if [ -f /usr/bin/VBoxManage ]; then
            VBOXMANAGE=/usr/bin/VBoxManage
        elif [ -f /usr/local/bin/VBoxManage ]; then
            VBOXMANAGE=/usr/local/bin/VBoxManage
        else
            if [ `find /usr -type f VBoxManage` ]; then
                VBOXMANAGE=`find /usr -type f VBoxManage`
            fi
        fi
        
        if [ `$VBOXMANAGE list extpacks | grep "Extension Packs" | tr -d ' ' | cut -d ':' -f2` == "0" ]; then
            VBversion=`$VBOXMANAGE -v`
            VBmajor="`echo ${VBversion} | cut -d 'r' -f 1`"
            VBminor="`echo ${VBversion} | cut -d 'r' -f 2`"
            if [ ! -f "$HOME/Downloads/Oracle_VM_VirtualBox_Extension_Pack-${VBmajor}-${VBminor}.vbox-extpack" ]; then
                if [ `which wget` ]; then
                    wget --quiet http://download.virtualbox.org/virtualbox/${VBmajor}/Oracle_VM_VirtualBox_Extension_Pack-${VBmajor}-${VBminor}.vbox-extpack -O $HOME/Downloads/Oracle_VM_VirtualBox_Extension_Pack-${VBmajor}-${VBminor}.vbox-extpack
                else
                    error_msg 'Could not use Wget to download VirtualBox Extension package!'
                fi
            fi
            if [ -f "$HOME/Downloads/Oracle_VM_VirtualBox_Extension_Pack-${VBmajor}-${VBminor}.vbox-extpack" ]; then
                output_msg "Installing VirtualBox Extension package..."
                echo "y" | sudo $VBOXMANAGE extpack install "$HOME/Downloads/Oracle_VM_VirtualBox_Extension_Pack-${VBmajor}-${VBminor}.vbox-extpack" > /dev/null
            else
                error_msg "Could not find VirtualBox extension pack!"
            fi
        fi
        
        # if [ ! -f $HOME/Library/VirtualBox/VirtualBox.xml ]; then
        #     output_msg "Importing VirtualBox configuration..."
        #     cp $SVN_LocalDir/Production/OSX/USER/VirtualBox.xml $HOME/Library/VirtualBox/VirtualBox.xml
        # fi
    fi
}

function VisualStudioCode {
    #~/Library/Application\ Support/Code/User/settings.json
    if [[ -f /Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code ]]; then
        for EXTENSION in bbenoist.vagrant DavidAnson.vscode-markdownlint jpogran.puppet-vscode liximomo.sftp ms-azuretools.vscode-docker ms-python.python ms-vscode.powershell streetsidesoftware.code-spell-checker vscode-icons-team.vscode-icons; do
            /Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code --install-extension ${EXTENSION}
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
    Brew
    Brew_Cask
    Brew_Packages
    Node_modules
    Python_modules
    Vagrant
    #VirtualBox
    VisualStudioCode
    OS_Setup
fi

exit 0