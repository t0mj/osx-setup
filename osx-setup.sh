#!/bin/bash

# A script to set up a new mac. Uses bash, homebrew, etc.
# Run in terminal on a fresh mac, profit.
# Originally forked off of https://gist.github.com/somebox/6b00f47451956c1af6b4
# Beefed up and made repo for my custom configs and python.

# helpers
function echo_ok { echo '\033[1;32m'"$1"'\033[0m'; }
function echo_warn { echo '\033[1;33m'"$1"'\033[0m'; }
function echo_error  { echo '\033[1;31mERROR: '"$1"'\033[0m'; }

echo_ok "Install starting. You may be asked for your password (for sudo)."

# requires xcode and tools!
xcode-select -p || exit "XCode must be installed! (use the app store)"

# requirements
echo_warn "Setting permissions..."
for dir in "/usr/local /usr/local/bin /usr/local/include /usr/local/lib /usr/local/share"; do
	sudo chgrp admin $dir
	sudo chmod g+w $dir
done

# homebrew
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
if hash brew &> /dev/null; then
	echo_ok "Homebrew already installed"
else
    echo_warn "Installing homebrew..."
	ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# moar homebrew...
brew install caskroom/cask/brew-cask
brew update && brew upgrade brew-cask && brew cleanup && brew cask cleanup

# brew taps
brew tap caskroom/versions
brew tap caskroom/fonts
brew tap homebrew/games

# Homebrew base
brew install \
  git go htop-osx jq mysql node postgres python readline sqlite \
	the_silver_searcher tig tmux unrar v8 vim wget youtube-dl zsh

# brew cask fonts
echo_warn "Installing fonts..."
brew cask install \
  font-anonymous-pro \
  font-dejavu-sans-mono-for-powerline \
  font-droid-sans \
  font-droid-sans-mono font-droid-sans-mono-for-powerline \
  font-meslo-lg font-input \
  font-inconsolata font-inconsolata-for-powerline \
  font-liberation-sans \
  font-meslo-lg \
  font-nixie-one \
  font-office-code-pro \
  font-pt-mono \
  font-roboto \
  font-source-code-pro \
  font-source-sans-pro \
  font-ubuntu font-ubuntu-mono-powerline


# brew cask quicklook
echo_warn "Installing QuickLook Plugins..."
brew cask install quicklook-csv quicklook-json animated-gif-quicklook

# Apps
echo_warn "Installing applications..."
brew cask install \
  battle-net caffeine dash dropbox elmedia-player flycut google-chrome-canary \
	hyperdock slack steam transmission

# Development Tools
echo_warn "Installing dev tools..."
brew cask install \
	adafruit-arduino atom iterm2 sequel-pro
echo_warn "Installing Oh My ZSH..."
sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

# Python Packages
echo_warn "Installing Python packages..."
pip install flake8 ipython jupyter pss virtualenv

# Gems
echo_warn "Installing gems..."
sudo gem install bropages

# Ionic framework
echo_warn "Installing node packages..."
sudo npm install -g cordova
sudo npm install -g ionic
sudo npm install -g yo
sudo npm install -g bower gulp nodemon

# Custom vimrc, tmux, zsh and atom files
echo_warn "Setting up custom configs..."
ln -s ~/osx-setup/configs/VimConfig/.vim ~/.vim
ln -s ~/osx-setup/configs/VimConfig/.vimrc ~/.vimrc
ln -s ~/osx-setup/configs/VimConfig/.vimrc_custom ~/.vimrc_custom
ln -s ~/osx-setup/configs/VimConfig/.gvimrc ~/.gvimrc
ln -s ~/osx-setup/configs/.atom ~/.atom
ln -s ~/osx-setup/configs/.gitconfig ~/.gitconfig
ln -s ~/osx-setup/configs/.tmux.conf ~/.tmux.conf
ln -s ~/osx-setup/configs/.zshrc ~/.zshrc
cd ~/osx-setup/configs/VimConfig/.vim/bundle/neobundle.vim
git checkout master
git pull --rebase
cd ~/osx-setup

# xquartz
echo_warn "Installing xquartz (this big download can be slow)"
n=0
until [ $n -ge 20 ]; do
	brew cask install xquartz && break
	n=$[$n+1]
	echo_error "... install failed, retry $n"
done
brew cask install inkscape

echo_warn "Finalizing setup..."
mysql_secure_installation
# Run battle.net installer
cd /opt/homebrew-cask/Caskroom/battle-net/latest/Battle.net-Setup-enUS.app/Contents/MacOS/
./Battle.net\ Setup
cd ~/osx-setup

echo
echo_ok "Done."
echo
echo "Next generate and add SSH keys to github:"
echo "    https://help.github.com/articles/generating-ssh-keys/"
echo
