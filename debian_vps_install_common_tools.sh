# 此文件是为了快速在新的debian vps上安装常用组件及hack tools

# 安装基础依赖
apt-get update -y && apt-get install python python3 python-pip python3-pip tmux unzip docker.io cmake jq nmap npm chromium parallel libssl-dev libffi-dev -y

# 安装python3依赖
pip3 install requests lxml tldextract flask simplejson

# 安装golang
version=$(curl -L -s https://golang.org/VERSION?m=text)
if [[ $(eval type go $DEBUG_ERROR | grep -o 'go is') == "go is" ]] && [ "$version" = $(go version | cut -d " " -f3) ]; then
    printf "Golang is already installed and updated\n\n"
else
    eval wget https://dl.google.com/go/${version}.linux-amd64.tar.gz
    eval tar -C /usr/local -xzf ${version}.linux-amd64.tar.gz
fi
eval ln -sf /usr/local/go/bin/go /usr/local/bin/
rm -rf $version*
cat <<EOF >>~/.bashrc
# Golang vars
export GOROOT=/usr/local/go
export GOPATH=\$HOME/go
export PATH=\$GOPATH/bin:\$GOROOT/bin:\$HOME/.local/bin:\$PATH
EOF

# 验证go是否安装成功
go version

# 如果go安装成功，安装常用的go tools
go install -v github.com/tomnomnom/assetfinder@latest
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go install -v github.com/ffuf/ffuf@latest
go install -v github.com/tomnomnom/qsreplace@latest
go install -v github.com/lc/gau@latest
go install -v github.com/tomnomnom/unfurl@latest
go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
go install -v github.com/tomnomnom/anew@latest
go install -v github.com/projectdiscovery/chaos-client/cmd/chaos@latest
cd ~/ && git clone https://github.com/shmilylty/OneForAll && cd OneForAll/ && pip3 install -r requirements.txt
go install -v github.com/tomnomnom/gf@latest && mkdir ~/.gf && cd ~/.gf && git clone https://github.com/tomnomnom/gf/ && cp gf/examples/*.json ./ && git clone https://github.com/1ndianl33t/Gf-Patterns && cp Gf-Patterns/*.json ./