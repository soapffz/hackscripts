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
fi

# Configure Go environment if it's not already configured
if ! grep -q "GOROOT" ~/.bashrc; then
    cat <<EOF >>~/.bashrc
# Golang vars
export GOROOT=/usr/local/go
export GOPATH=\$HOME/go
export PATH=\$GOPATH/bin:\$GOROOT/bin:\$HOME/.local/bin:\$PATH
EOF
    source ~/.bashrc
fi

# Install dependencies and tools
sudo apt-get update -yq >/dev/null
sudo apt-get install -yq tmux unzip docker.io cmake jq nmap npm chromium parallel libssl-dev libffi-dev >/dev/null
pip3 install requests lxml tldextract flask simplejson >/dev/null

# Install Go tools if Go is installed
if type go >/dev/null 2>&1; then
    go install -v github.com/tomnomnom/assetfinder@latest
    go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
    go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
    go install -v github.com/ffuf/ffuf@latest
    go install -v github.com/tomnomnom/qsreplace@latest
    go install -v github.com/lc/gau@latest
    go install -v github.com/tomnomnom/unfurl@latest
    go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
    go install -v github.com/tomnomnom/anew@latest
    go install -v github.com/projectdiscovery/chaos-client/cmd
fi

echo "Done installing dependencies and tools."
