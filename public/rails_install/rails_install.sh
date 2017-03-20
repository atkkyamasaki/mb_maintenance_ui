#!bin/bash

echo '=========== yum -y install openssl-devel readline-devel zlib-devel libcurl-devel ==========='
    yum -y install openssl-devel readline-devel zlib-devel libcurl-devel
echo -e "\n\n"


echo '=========== cd /usr/local ==========='
    cd /usr/local
echo -e "\n\n"


echo '=========== git clone git://github.com/sstephenson/rbenv.git rbenv ==========='
    git clone git://github.com/sstephenson/rbenv.git rbenv
echo -e "\n\n"


echo '=========== mkdir rbenv/shims ==========='
    mkdir rbenv/shims
echo -e "\n\n"


echo '=========== mkdir rbenv/versions ==========='
    mkdir rbenv/versions
echo -e "\n\n"


echo '=========== mkdir rbenv/plugins ==========='
    mkdir rbenv/plugins
echo -e "\n\n"


echo '=========== groupadd rbenv ==========='
    groupadd rbenv
echo -e "\n\n"


echo '=========== chgrp -R rbenv rbenv ==========='
    chgrp -R rbenv rbenv
echo -e "\n\n"


echo '=========== chmod -R g+rwxXs rbenv ==========='
    chmod -R g+rwxXs rbenv
echo -e "\n\n"


echo '=========== cd /usr/local/rbenv/plugins ==========='
    cd /usr/local/rbenv/plugins
echo -e "\n\n"


echo '=========== git clone git://github.com/sstephenson/ruby-build.git ruby-build ==========='
    git clone git://github.com/sstephenson/ruby-build.git ruby-build
echo -e "\n\n"


echo '=========== chgrp -R rbenv ruby-build ==========='
    chgrp -R rbenv ruby-build
echo -e "\n\n"


echo '=========== chmod -R g+rwxs ruby-build ==========='
    chmod -R g+rwxs ruby-build
echo -e "\n\n"


echo '=========== git clone git://github.com/sstephenson/rbenv-default-gems.git rbenv-default-gems ==========='
    git clone git://github.com/sstephenson/rbenv-default-gems.git rbenv-default-gems
echo -e "\n\n"


echo '=========== chgrp -R rbenv rbenv-default-gems ==========='
    chgrp -R rbenv rbenv-default-gems
echo -e "\n\n"


echo '=========== chmod -R g+rwxs rbenv-default-gems ==========='
    chmod -R g+rwxs rbenv-default-gems
echo -e "\n\n"


echo '=========== echo 'export RBENV_ROOT="/usr/local/rbenv"' > /etc/profile.d/rbenv.sh ==========='
    echo 'export RBENV_ROOT="/usr/local/rbenv"' > /etc/profile.d/rbenv.sh
echo -e "\n\n"


echo '=========== echo 'export PATH="$RBENV_ROOT/bin:$PATH"' >> /etc/profile.d/rbenv.sh ==========='
    echo 'export PATH="$RBENV_ROOT/bin:$PATH"' >> /etc/profile.d/rbenv.sh
echo -e "\n\n"


echo '=========== echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh ==========='
    echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh
echo -e "\n\n"


echo '=========== echo 'bundler' > /usr/local/rbenv/default-gems ==========='
    echo 'bundler' > /usr/local/rbenv/default-gems
echo -e "\n\n"


echo '=========== echo 'rbenv-rehash' >> /usr/local/rbenv/default-gems ==========='
    echo 'rbenv-rehash' >> /usr/local/rbenv/default-gems
echo -e "\n\n"


echo '=========== source /etc/profile.d/rbenv.sh ==========='
    source /etc/profile.d/rbenv.sh
echo -e "\n\n"


echo '=========== rbenv install 2.2.5 ==========='
    rbenv install 2.2.5
echo -e "\n\n"


echo '=========== rbenv global 2.2.5 ==========='
    rbenv global 2.2.5
echo -e "\n\n"


echo '=========== yum -y install sqlite-devel ==========='
    yum -y install sqlite-devel
echo -e "\n\n"


echo '=========== gem install sqlite3-ruby ==========='
    gem install sqlite3-ruby
echo -e "\n\n"


echo '=========== gem install uglifier ==========='
    gem install uglifier
echo -e "\n\n"


echo '=========== gem install turbolinks ==========='
    gem install turbolinks
echo -e "\n\n"


echo '=========== yum -y install epel-release ==========='
    yum -y install epel-release
echo -e "\n\n"


echo '=========== yum -y install nodejs ==========='
    yum -y install nodejs
echo -e "\n\n"


echo '===========  gem install rails==========='
    gem install rails
echo -e "\n\n"


echo '=========== cd /var/www/mb_maintenance_ui ==========='
    cd /var/www/mb_maintenance_ui
echo -e "\n\n"


echo '=========== bundle install ==========='
    bundle install
echo -e "\n\n"

echo '=========== webrick 起動時有効化 ==========='
    echo "/bin/su - root -c 'sh /var/www/mb_maintenance_ui/webrick start'" >> /etc/rc.d/rc.local
echo -e "\n\n"
