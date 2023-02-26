#!/bin/bash

# 此文件是为了快速在新的debian vps上安装常用组件及hack tools
# 直接使用方法：wget https://raw.githubusercontent.com/soapffz/hacktips/main/debian_vps_install_common_tools.sh && chmod +x debian_vps_install_common_tools.sh && ./debian_vps_install_common_tools.sh && ./debian_vps_install_common_tools.sh

set -e

# Check if Go is installed
if ! type go >/dev/null 2>&1; then
    # Install Go
    version=$(curl -L -s https://golang.org/VERSION?m=text)
    echo "Downloading Golang $version"
    wget --progress=bar:force https://dl.google.com/go/${version}.linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf ${version}.linux-amd64.tar.gz
    rm -rf $version*
fi

# Configure Go environment
if ! grep -q "GOROOT" ~/.bashrc; then
    cat <<EOF >>~/.bashrc
# Golang vars
export GOROOT=/usr/local/go
export GOPATH=\$HOME/go
export PATH=\$GOPATH/bin:\$GOROOT/bin:\$HOME/.local/bin:\$PATH
EOF
fi
source ~/.bashrc

# Install dependencies and tools
sudo apt-get update -yq
sudo apt-get install -yq tmux unzip docker.io cmake jq nmap npm chromium parallel libssl-dev libffi-dev
pip3 install requests lxml tldextract flask simplejson

install_go_tools() {
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
}

if type go >/dev/null 2>&1; then
    install_go_tools
else
    printf "Golang is not installed, skipping installation of Go tools.\n\n"
fi

echo "Done installing dependencies and tools."
