#!/usr/bin/env bash

#Variables
APPENV=local
DBHOST=localhost

echo -e "\n--- Provisioning virtual machine... ---\n"
apt autoremove
apt-get update
apt-get upgrade -y

echo -e "\n---Installing Git... ---\n"
apt-get install git -y

echo -e "\n--- Adding repos ---\n"
apt-get install python-software-properties build-essential -y

echo -e "\n--- Installing curl and wget ---\n"
apt-get install curl wget -y

echo -e "\n--- Installing Apache 2.4 ---\n"
apt-get install apache2 -y

echo -e "\n--- Installing PHP ---\n"
apt-get install php7.0-common php7.0-dev php7.0-cli php7.0-fpm -y
apt-get install php7.0 -y

echo -e "\n--- Installing PHP extensions... ---\n"
apt-get install php7.0-curl php7.0-gd php7.0-mcrypt php7.0-mysql php7.0-soap php7.0-opcache php-memcached php7.0-json php7.0-iconv php7.0-bcmath php7.0-mbstring php7.0-xml php7.0-zip libapache2-mod-php7.0 php7.0-intl -y

echo -e "\n--- Installing OpenSSL ---\n"
apt-get install openssl -y

echo -e "\n--- Restarting Apache ---\n"
service apache2 restart

echo -e "\n--- Add environment variables to Apache ---\n"
cat > /etc/apache2/sites-available/testsite.conf <<EOF
ServerName testsite
<VirtualHost *:80>
    DocumentRoot "/var/www"
    ServerName localhost
</VirtualHost>
<VirtualHost *:80>
    DocumentRoot "/var/www/html"
    ServerName testsite
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
    SetEnv APP_ENV $APPENV
</VirtualHost>
EOF

echo -e "\n--- Enabling modrewrite ---\n"
a2enmod rewrite

echo -e "\n--- Allowing Apache override to all ---\n"
sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf

echo -e "\n--- Enabling sites ---\n"
a2ensite testsite.conf

echo -e "\n--- Restarting Apache ---\n"
sudo service apache2 restart

echo -e "\n--- Installing Composer ---\n"
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/bin/composer

echo -e "\n--- Setting up VIM ---\n"
touch .vimrc
mkdir .vim 
mkdir .vim/colors
mkdir .vim/bundle

echo -e "\n--- Installing vim colorscheme ---\n"
wget https://raw.githubusercontent.com/crusoexia/vim-monokai/master/colors/monokai.vim -P /home/vagrant/.vim/colors/

echo -e "\n--- Installing Vundle ---\n"
git clone https://github.com/VundleVim/Vundle.vim.git /home/vagrant/.vim/bundle/Vundle.vim

sudo chown -R vagrant:vagrant /home/vagrant
echo -e "\n--- Configuring vimrc ---\n"
cat > .vimrc << EOF
set nocompatible
filetype off

"set runtime path for Vundle and init
set rtp+=/home/vagrant/.vim/bundle/Vundle.vim
call vundle#begin()

"List the plugins
"Let Vundle handle itself
Plugin 'VundleVim/Vundle.vim'
"Multiple cursors Sublime style
Plugin 'terryma/vim-multiple-cursors'
"Supertab - auto completion on tab
Plugin 'ervandew/supertab'
"NERDTree
Plugin 'wycats/nerdtree'
"Syntastic
Plugin 'vim-syntastic/syntastic'
"Vim surround
Plugin 'tpope/vim-surround'
"Vim commentary
Plugin 'tpope/vim-commentary'
"Auto completion of brackets, quotes, parens etc
Plugin 'Raimondi/delimitMate'

call vundle#end()
filetype plugin indent on

set background=dark
syntax enable
try
	colorscheme monokai
	set t_Co=256
catch
endtry
set hidden
set tabstop=4
set autoindent
set copyindent
set number
set shiftwidth=4
set showmatch
set ignorecase
set smarttab
set hlsearch
set incsearch
set history=300
set undolevels=1000
set pastetoggle=<F2>
set mouse=a

"Syntastic config
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntast_check_on_open = 1
let g:syntastic_check_on_wq = 0

"NERDtree toggle
map <C-t> :NERDTreeToggle<CR>
EOF

echo -e "\n--- Changing directory colors ---\n"
cat > .bashrc << EOF
#changing directory colors
LS_COLORS=$LS_COLORS:'di=1;91:fi=0;97:ex=0;36';
export LS_COLORS
EOF

echo -e "\n--- Configuring bash_profile ---\n"
cat > .bash_profile << EOF
#load bashrc if exists
if [ -f ~/.bashrc ];
then
	. ~/bashrc
fi

#display current git branch if applicable
parse_git_branch() {
	git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

export PS1="\u@\h \[\033[93m\]\w\[\033[95m\]\$(parse_git_branch)\[\033[00m\] $ "
EOF

echo -e "\n--- Don't forget to install MySQL ---\n"
echo -e "\n--- Have Fun ---\n"
