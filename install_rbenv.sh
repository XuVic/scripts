ubuntu_version="$(lsb_release -a | grep Release)"
ubuntu_version=($ubuntu_version)
ubuntu_version=${ubuntu_version[1]}

installed="$(rbenv --version)"

function install_dependencies
{
   sudo curl -sL https://deb.nodesource.com/setup_10.x
   sudo apt-get install -y autoconf bison build-essential libssl-dev \
        libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev \
        libffi-dev libgdbm3 libgdbm-dev ruby-dev libpq-dev patch \
        liblzma-dev nodejs gcc g++ make git
}

if [[ -n "$installed" ]]; then
    echo "$installed"
    ruby -v
elif [ "$ubuntu_version" == "16.04" ]; then
    sudo apt-get update
    install_dependencies
    git clone https://github.com/rbenv/rbenv.git ~/.rbenv
    git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
    sudo bash ~/.rbenv/plugins/ruby-build
    sudo echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
    sudo echo 'eval "$(rbenv init -)"' >> ~/.bashrc
    sudo source ~/.bashrc
    type rbenv
    rbenv --version
elif [ "$ubuntu_version" == "18.04" ]; then
    echo 'Noting happends'
fi
