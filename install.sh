#! /bin/bash

echo "Installing all the packages"

home=$(pwd)
bash_file=~/.bashrc

# Checking if package is installed else install it
function checkOrInstall(){
	REQUIRED_PKG=$1
    PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "Already Installed")

	echo Checking for $REQUIRED_PKG: $PKG_OK

	if [ "" = "$PKG_OK" ]; then
		echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
		sudo apt install -y $REQUIRED_PKG
	fi
}

# Find dir of python3 packages
function searchPythonPackages(){
	python_version=$(python3 --version)
	packages=($(find / ! \( -path /mnt -prune \) -type $2 2> /dev/null | grep $1))
	
	for package in ${packages[@]}
	do
		if [[ "$package" == *"${python_version:7}"* ]]; then
			echo $package
		fi
    done
}

sudo apt update

checkOrInstall python3
checkOrInstall wget
checkOrInstall curl
checkOrInstall git
checkOrInstall vim
checkOrInstall unzip
checkOrInstall python3-pip 
checkOrInstall grep

# neovim
wget https://github.com/neovim/neovim/releases/download/v0.7.2/nvim-linux64.deb
sudo apt install -y ./nvim-linux64.deb

rm -r nvim-linux64.deb

# powerline
pip3 install --user powerline-status
pip3 install powerline-gitstatus

mkdir -p ~/.config/powerline/colorschemes
mkdir -p ~/.config/powerline/themes/shell

cd ~/.config/powerline/colorschemes/
git clone --depth 1 https://gist.github.com/39a60757df3d8bbca99d96811561d409.git my-color-scheme
mv my-color-scheme/my-powerline-colorscheme.json default.json
sudo rm -r my-color-scheme

cd ~/.config/powerline/themes/shell/
git clone --depth 1 https://gist.github.com/03a4e4eb58038e9e683b1f839fd63250.git  my-shell-scheme
mv my-shell-scheme/my-powerline-shell-theme.json default.json
sudo rm -r my-shell-scheme

cd $home

powerline_sh="$(searchPythonPackages 'bash/powerline.sh' 'f')"
powerline_daemon="$(searchPythonPackages 'bin/powerline-daemon' 'f')"

powerline_daemon_loc=${powerline_daemon%"powerline-daemon"*}

echo '' >> $bash_file
echo '' >> $bash_file
echo '# Powerline' >> $bash_file
echo 'export PATH="$PATH:'$powerline_daemon_loc'"' >> $bash_file
echo 'export LC_ALL=en_US.UTF-8' >> $bash_file
echo 'powerline-daemon -q' >> $bash_file
echo 'POWERLINE_BASH_CONTINUATION=1' >> $bash_file
echo 'POWERLINE_BASH_SELECT=1' >> $bash_file
echo 'source' $powerline_sh >> $bash_file

source ~/.bashrc
