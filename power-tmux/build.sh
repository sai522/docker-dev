#!/usr/bin/env bash

# Print out every line being run
set -x

# If a command fails, exit immediately.
set -e

apt-install() {
	sudo apt-get install --no-install-recommends -y "$@"
}

install-tmux() {
	local tmuxVersion=2.3
	local tmuxTar="tmux-$tmuxVersion.tar.gz"
	pushd /tmp
	curl -L -o "/tmp/tmux-$tmuxVersion.tar.gz" \
		"https://github.com/tmux/tmux/releases/download/$tmuxVersion/$tmuxTar"
	tar xzf "$tmuxTar"
	local tmuxSrc="/tmp/tmux-$tmuxVersion"
	pushd "$tmuxSrc"
	# libevent-2.0-5 is a run-time requirement.
	apt-install libevent-2.0-5 libevent-dev libncurses-dev
	./configure
	make
	sudo make install
	popd
	rm -rf "$tmuxSrc"
	rm -rf "$tmuxTar"
	sudo apt-get purge -y libevent-dev libncurses-dev
	popd
}

install-powerline() {
	# POWER TMUX
	sudo pip install powerline-status

	# Make git status extra nice :)
	sudo pip install powerline-gitstatus
}

install-tmate() {
	curl -o /tmp/tmate.tar.gz -L https://github.com/tmate-io/tmate/releases/download/2.2.1/tmate-2.2.1-static-linux-amd64.tar.gz
	tar -xzf /tmp/tmate.tar.gz -C /tmp
	sudo cp /tmp/tmate-2.2.1-static-linux-amd64/tmate /usr/local/bin/tmate
}

sudo apt-get update

# Fix file permissions from the copy
sudo chown -R aghost-7:aghost-7 "$HOME/.config"
sudo chown aghost-7:aghost-7 /home/aghost-7/.tmux.conf
sudo chown $USER:$USER ~/.tmate.conf

# Need to update package cache...
sudo apt-get update

# We're going to want utf-8 support...
apt-install language-pack-en-base

install-powerline

install-tmux

install-tmate

# Add fzf fuzzy finder
git clone https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all

# Add bashrc addons for powerline and etc.
cat /tmp/bashrc-additions.sh >> "$HOME/.bashrc"
sudo rm /tmp/bashrc-additions.sh

# Cleanup cache
sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/*
sudo apt-get autoremove -y
