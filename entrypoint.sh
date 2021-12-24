#! /bin/bash

if [ -d "/data" ]; then
    if [ -f "/data/etc/apt/sources.list" ]; then
        echo "System exists. exit."
        exit 0
    fi

    apt update
    apt install debootstrap wget ca-certificates -y 
    debootstrap focal /data http://archive.ubuntu.com/ubuntu
    rm /data/etc/apt/sources.list -rfv
    wget https://raw.githubusercontent.com/ChaunceyShannon/aapanel-kubernetes/main/ubuntu20.04.sources.list -O /data/etc/apt/sources.list
else 
    if [ ! -f "/etc/apt/sources.list" ]; then
        echo "System not exists. exit."
        exit 1
    fi

    if [ ! -f "/usr/sbin/sshd" ]; then
        echo "sshd not exists, installing..."
        apt update
        DEBIAN_FRONTEND=noninteractive apt install locales vim curl wget libasound2 libxss1 libnss3 sudo openssh-server x11-apps libgl1-mesa-glx libgtk-3-0 libglu1-mesa xfonts-wqy ttf-wqy-microhei ttf-wqy-zenhei -y 
        mkdir -p /run/sshd 
        tail -n +5 /etc/locale.gen | sed 's/# //g' > /tmp/f
        mv /tmp/f /etc/locale.gen
        locale-gen
        echo "export LANG='en_US.UTF-8'" >> /root/.bashrc 
        echo "export LANGUAGE='en_US.UTF-8'" >> /root/.bashrc
        echo "export LC_ALL='en_US.UTF-8'" >> /root/.bashrc

        grep 'PermitRootLogin yes' /etc/ssh/sshd_config || echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config

        echo "Start ssh server.."
        /usr/sbin/sshd -D -o ListenAddress=0.0.0.0 & 
    else 
        grep 'PermitRootLogin yes' /etc/ssh/sshd_config || echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
        mkdir -p /run/sshd 

        echo "Start ssh server.."  
        /usr/sbin/sshd -D -o ListenAddress=0.0.0.0 & 
    fi

    if [ ! -d "/www/server/panel" ]; then
        echo "AAPannel not exists, installing..."

        apt update
        DEBIAN_FRONTEND=noninteractive apt-get install vim sudo curl ruby lsb-release ntp ntpdate wget curl sqlite libcurl4-openssl-dev gcc make zip unzip tar openssl libssl-dev gcc libxml2 libxml2-dev zlib1g zlib1g-dev libjpeg-dev libpng-dev lsof libpcre3 libpcre3-dev cron net-tools swig build-essential libffi-dev libbz2-dev libncurses-dev libsqlite3-dev libreadline-dev tk-dev libgdbm-dev libdb-dev libdb++-dev libpcap-dev xz-utils git unzip ufw -y

        wget -O install.sh http://www.aapanel.com/script/install-ubuntu_6.0_en.sh
        echo y | bash install.sh aapanel | tee /root/bt.install.log

        sleep infinity
    else 
        echo "AAPannel exists, start service..."

        /www/server/panel/pyenv/bin/python /www/server/panel/BT-Panel
        /www/server/panel/pyenv/bin/python /www/server/panel/BT-Task &

        if [ -f "/www/server/nginx/sbin/nginx" ]; then 
            /www/server/nginx/sbin/nginx -c /www/server/nginx/conf/nginx.conf
        fi 

        if [ -f "/www/server/redis/src/redis-server" ]; then
            /www/server/redis/src/redis-server 127.0.0.1:6379 &
        fi

        if [ -f "/etc/rc.local" ]; then
            bash /etc/rc.local &
        fi

        if [ -f "/www/server/mysql/bin/mysqld" ]; then 
            /www/server/mysql/bin/mysqld --basedir=/www/server/mysql --datadir=/www/server/data --plugin-dir=/www/server/mysql/lib/plugin --user=mysql --log-error=ubuntu.err --open-files-limit=65535 --pid-file=/www/server/data/ubuntu.pid --socket=/tmp/mysql.sock --port=3306 & mysqlpid="$!"

            handle_sigterm() {
                echo "[INFO] Received SIGTERM"
                kill -SIGTERM $mysqlpid
                wait $mysqlpid
            }
            trap handle_sigterm SIGTERM

            wait 
            exit
        fi
        
        sleep infinity
    fi
fi
