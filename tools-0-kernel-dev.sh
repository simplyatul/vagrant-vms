#!/bin/bash
# Packages required to build kernel
# Contains some optional packages as well

sudo apt update
sudo apt install -y bison flex
sudo apt install -y build-essential linux-headers-$(uname -r) tar ncurses-dev libssl-dev \
    bc libelf-dev net-tools linux-tools-$(uname -r) exuberant-ctags cscope libncurses5-dev \
    zstd
