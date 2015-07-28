#!/bin/bash

# 既に実行済みであれば終了
test -f /etc/bootstrapped && exit

# Firewall, SELinuxの設定
sudo service iptables stop
sudo chkconfig iptables off
sudo cp -p /etc/selinux/config /etc/selinux/config.bk
sed -i -e "s|^SELINUX=.*|SELINUX=disable|" /etc/selinux/config

# Network遅延の対応
sudo echo "options single-request-reopen" | sudo tee -a /etc/resolv.conf

# Timezoneの設定
sudo cp /usr/share/zoneinfo/Japan /etc/localtime

# rpmforge, epel, remiのリポジトリを追加
sudo rpm -ivh http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
sudo rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
sudo rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
sudo yum --disablerepo=epel -y update  ca-certificates

# デフォルトで上記リポジトリを使わないように変更
sudo sed -i -e "s/enabled = 1/enabled = 0/g" /etc/yum.repos.d/rpmforge.repo
sudo sed -i -e "s/enabled = 1/enabled = 0/g" /etc/yum.repos.d/epel.repo
sudo sed -i -e "s/enabled = 2/enabled = 0/g" /etc/yum.repos.d/remi.repo

# ライブラリをアップデート
sudo yum -y update

# 必要なライブラリのインストール（git）
sudo yum install git -y
git config --global user.name "fortkle"
git config --global user.email fortkle@gmail.com

# 必要なライブラリのインストール（PHP5.4.42）
sudo yum -y install --enablerepo=remi php php-pdo php-devel php-mbstring php-mcrypt php-mysql php-phpunit-PHPUnit php-pecl-xdebug php-cli php-common gd-last ImageMagick-last

# 必要なライブラリのインストール（Apache）
sudo yum -y install httpd
sudo chkconfig httpd on
sudo service httpd start

# 必要なライブラリのインストール（MySQL）
sudo yum -y install --enablerepo=remi mysql mysql-devel mysql-server mysql-utilities
sudo touch /var/lib/mysql/mysql.sock
sudo chown mysql:mysql /var/lib/mysql
sudo /etc/init.d/mysqld restart

# 必要なライブラリのインストール（ag）
sudo yum install pcre pcre-devel -y
sudo yum install xz xz-devel -y

# 必要なライブラリのインストール（tmux）
sudo yum install curl
sudo yum install wget gcc make
sudo yum install ncurses ncurses-devel

# フォルダの作成
cd ~/
mkdir ~/src
mkdir ~/bin
mkdir -p ~/local/bin
ln -snf .dotfiles/.bashrc

# Vim7.4のインストール
sudo yum -y install gcc
sudo yum install ncurses-devel
cd ~/src
wget ftp://ftp.vim.org/pub/vim/unix/vim-7.4.tar.bz2
tar jxvf vim-7.4.tar.bz2
cd vim74/
./configure --with-features=huge --enable-xim --enable-fontset --enable-multibyte --enable-rubyinterp --prefix=$HOME/local
make
make install
cd ~/bin
ln -s ~/local/bin/vim
source ~/.bash_profile

# vimrcの設定
cd ~/
git clone https://github.com/fortkle/dotfiles.git .dotfiles
ln -s .dotfiles/.vimrc
mkdir -p ~/.vim/bundle
git clone https://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim
#cd ~/.vim/bundle/vimproc/
#sudo make -f make_unix.mak

# tmuxのインストール
cd ~/src
curl -L https://github.com/downloads/libevent/libevent/libevent-2.0.21-stable.tar.gz -o libevent-2.0.21-stable.tar.gz
tar xvzf libevent-2.0.21-stable.tar.gz
cd libevent-2.0.21-stable
./configure --prefix=$HOME/local/libevent
make && make install
echo $HOME/local/libevent/lib > libevent.conf
sudo mv libevent.conf /etc/ld.so.conf.d/libevent.conf
sudo ldconfig

cd ~/src
wget http://downloads.sourceforge.net/tmux/tmux-1.8.tar.gz
tar xvzf tmux-1.8.tar.gz
cd tmux-1.8
DIR="$HOME/local/libevent/"
./configure CFLAGS="-I$DIR/include" LDFLAGS="-L$DIR/lib" --prefix=$HOME/local
make && make install
cd ~/
ln -s .dotfiles/.tmux.conf
cd ~/bin
ln -s ~/local/bin/tmux

# silver searcher (ag)のインストール
cd ~/src
git clone https://github.com/ggreer/the_silver_searcher.git
cd the_silver_searcher/
git checkout refs/tags/0.24.1
./build.sh
sudo make install

# zshのインストール
cd ~/
sudo yum install zsh -y
ln -s .dotfiles/.zshrc

# pecoのインストール
cd ~/src
wget -O peco_linux_amd64.tar.gz https://github.com/peco/peco/releases/download/v0.2.11/peco_linux_amd64.tar.gz --no-check-certificate
tar -C ~/src -xzf peco_linux_amd64.tar.gz
cp -rp ~/src/peco_linux_amd64/peco ~/local/bin/
cd ~/bin
ln -s ~/local/bin/peco peco
cd ~/
ln -s .dotfiles/.config


# Provisioning Completed
cd ~
date > bootstrapped
sudo mv bootstrapped /etc/bootstrapped
