#!/bin/bash

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root"
    exit 1
fi

# Update package list first
apt-get update

# Install system packages
PACKAGES="parallel jq python3 python3-pip unzip python3-shodan"
apt-get install -y $PACKAGES

# Install Python packages 
pip3 install censys

# Set Go installation directory
GOBIN="${PWD}/bin"
mkdir -p "$GOBIN"
export PATH="$PATH:$GOBIN"
# Function to install Go packages
install_go_package() {
    echo "Installing $1..."
    GOBIN="$GOBIN" GO111MODULE=on go install -v "$1"@"${2:-latest}"
}

# Install Go tools
GO_PACKAGES=(
    "github.com/projectdiscovery/subfinder/v2/cmd/subfinder"
    "github.com/owasp-amass/amass/v3/... master"
    "github.com/tomnomnom/assetfinder"
    "github.com/projectdiscovery/chaos-client/cmd/chaos"
    "github.com/hakluke/haktrails"
    "github.com/lc/gau/v2/cmd/gau"
    "github.com/gwen001/github-subdomains"
    "github.com/gwen001/gitlab-subdomains"
    "github.com/glebarez/cero"
    "github.com/incogbyte/shosubgo"
    "github.com/projectdiscovery/httpx/cmd/httpx"
    "github.com/tomnomnom/anew"
    "github.com/tomnomnom/unfurl"
    "github.com/d3mondev/puredns/v2"
    "github.com/projectdiscovery/dnsx/cmd/dnsx"
)

for package in "${GO_PACKAGES[@]}"; do
    read -r pkg version <<< "$package"
    install_go_package "$pkg" "$version"
done

# Install massdns
echo "Installing massdns..."
git clone https://github.com/blechschmidt/massdns.git
(cd massdns && make && make install)
rm -rf massdns

# Download additional resources
echo "Downloading additional resources..."
git clone https://github.com/trickest/resolvers
wget -O best-dns-wordlist.txt https://wordlists-cdn.assetnote.io/data/manual/best-dns-wordlist.txt
wget https://raw.githubusercontent.com/lc/gau/master/.gau.toml

# Install findomain
echo "Installing findomain..."
wget https://github.com/Findomain/Findomain/releases/download/8.2.1/findomain-linux.zip
unzip findomain-linux.zip
chmod +x findomain
mv findomain /usr/bin/
rm findomain-linux.zip

echo "Installation completed successfully!"
