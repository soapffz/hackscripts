#!/bin/bash

# 此文件是为了快速在新的debian vps上安装常用组件及hack tools
# 直接使用方法：wget https://raw.githubusercontent.com/soapffz/hacktips/main/debian_vps_install_common_tools.sh && chmod +x debian_vps_install_common_tools.sh && sudo ./debian_vps_install_common_tools.sh

set -e

# Install Go if it's not already installed
if ! type go >/dev/null 2>&1; then
    version=$(curl -L -s https://golang.org/VERSION?m=text)
    wget -q --show-progress --progress=bar:force https://dl.google.com/go/${version}.linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf ${version}.linux-amd64.tar.gz
    rm -rf $version*
    echo "Go has been installed successfully."
else
    echo "Go is already installed."
fi

# Configure Go environment if it's not already configured
if ! grep -q "GOROOT" ~/.bashrc; then
    cat <<EOF >>~/.bashrc
# Golang vars
export GOROOT=/usr/local/go
export GOPATH=\$HOME/go
export PATH=\$GOPATH/bin:\$GOROOT/bin:\$HOME/.local/bin:\$PATH
EOF
    echo "Go environment has been configured successfully."
else
    echo "Go environment is already configured."
fi

# source ~/.bashrc
if [ -f ~/.bashrc ]; then
    source ~/.bashrc >/dev/null
    echo "Sourced ~/.bashrc successfully."
else
    echo "Cannot source ~/.bashrc, file does not exist."
fi

# Install dependencies and tools
sudo apt-get update -yq >/dev/null
sudo apt-get install -yq python python3 python-pip python3-pip tmux unzip docker.io cmake jq nmap npm chromium parallel libssl-dev libffi-dev >/dev/null
pip3 install requests lxml tldextract flask simplejson >/dev/null
echo "Dependencies and tools have been installed successfully."

# Install Go tools if Go is installed
if type go >/dev/null 2>&1; then
    echo "Installing Go tools..."
    
    go install -v github.com/projectdiscovery/pdtm/cmd/pdtm@latest  >/dev/null
    pdtm -install-all
    go install -v github.com/tomnomnom/assetfinder@latest >/dev/null
    go install -v github.com/ffuf/ffuf@latest >/dev/null
    go install -v github.com/tomnomnom/qsreplace@latest >/dev/null
    go install -v github.com/lc/gau@latest >/dev/null
    go install -v github.com/tomnomnom/unfurl@latest >/dev/null
    go install -v github.com/tomnomnom/anew@latest >/dev/null
    echo "Go tools have been installed successfully."
else
    echo "Go is not installed, skipping Go tools installation."
fi
