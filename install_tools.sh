function install_db
{
    if [ "$1" == "sqlite" ]; then
        sudo apt-get update
        sudo apt-get install -y sqlite3 libsqlite3-dev
        sqlite3 -version
    elif [ "$1" == "pg" ]; then
        sudo apt-get update
        sudo apt-get install -y postgresql postgresql-contrib libpq-dev
        systemctl status postgresql 
    elif [ "$1" == "mysql" ]; then
        sudo apt-get update
        sudo apt-get install mysql-server
        mysql_secure_installation
        systemctl status mysql.service
    elif [ "$1" == "redis" ]; then
        sudo apt-get update
        sudo apt-get install build-essential tcl
        cd /tmp
        sudo curl -O http://download.redis.io/redis-stable.tar.gz && tar xzvf redis-stable.tar.gz && cd redis-stable
        make test
        sudo make install
        sudo mkdir /etc/redis
        sudo cp /tmp/redis-stable/redis.conf /etc/redis
        cd ~
        echo "Go this link: https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-redis-on-ubuntu-16-04 for setup Redis"
    fi
}

function install_server
{   
    if [ "$1" == "nginx" ]; then
        sudo apt-get update
        sudo apt-get -y install nginx ufw
        sudo ufw allow 'Nginx HTTP'
        sudo systemctl status nginx
    fi
}

function install_other
{
    if [ "$1" == "docker" ]; then
        sudo apt-get update
        sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs)  stable" 
        sudo apt-get update
        sudo apt-get install docker-ce
        sudo usermod -a -G docker $USER
        docker -v
    fimvn
}

if [ "$1" == "sqlite" ] || [ "$1" == "pg" ]; then
    install_db "$1"
elif [ "$1" == "nginx" ]; then
    install_server "$1"
fi
