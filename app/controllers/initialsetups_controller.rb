class InitialsetupsController < ApplicationController

    def show

        @judges = [
            ['ホスト名', %x(hostname).chomp, 'localhost.localdomain'],
            ['Eth0 IP', %x(grep -E ^IPADDR /etc/sysconfig/network-scripts/ifcfg-eth0 | sed -e "s/IPADDR=//g" | sed -e 's/"//g' | tr -d '\n').chomp, '192.168.1.1'],
            ['Zabbix Proxy 設定', %x(grep ^Server= /usr/local/etc/zabbix_proxy.conf).chomp, 'Server=127.0.0.1'],
            ['Zabbix Agent 設定', %x(grep ^Server= /usr/local/etc/zabbix_agentd.conf).chomp, 'Server=127.0.0.1']
        ] 

    end

    def update

        # 固定パラメータ / patch で取得した内容を変数に格納
        @zbxSrvIp = '150.87.1.103'
        @mbName = params[:mb_name]
        @eth0Ip = params[:eth0_ip]
        @eth0Mask = params[:eth0_mask]
        @eth2Ip = params[:eth2_ip]
        @route = params[:route]

        # Log File 保存先と保存形式の指定
        @logDir = '/var/www/mb_maintenance_ui/public/initsetup.log'
        @logSetting = '1>> ' + @logDir + ' 2>&1'

        # (IBS へキッティング依頼分は省略)
        # `cp -f /var/www/mb_maintenance_ui/public/init_setup/config/etc/ntp.conf /etc/ntp.conf`    
        # `cp -f /var/www/mb_maintenance_ui/public/init_setup/config/etc/resolv.conf /etc/resolv.conf`    
        # `cp -f /var/www/mb_maintenance_ui/public/init_setup/config/etc/rsyslog.conf /etc/rsyslog.conf`    
        # `cp -f /var/www/mb_maintenance_ui/public/init_setup/config/etc/logrotate.conf /etc/logrotate.conf`    
        # `cp -f /var/www/mb_maintenance_ui/public/init_setup/config/etc/xinetd.d/tftp /etc/xinetd.d/tftp`    
        # `cp -f /var/www/mb_maintenance_ui/public/init_setup/config/etc/logrotate.d/remote /etc/logrotate.d/remote`    
        # `cp -f /var/www/mb_maintenance_ui/public/init_setup/config/usr/local/etc/zabbix_agentd.conf /usr/local/etc/zabbix_agentd.conf`    
        # `cp -f /var/www/mb_maintenance_ui/public/init_setup/config/usr/local/etc/zabbix_proxy.conf /usr/local/etc/zabbix_proxy.conf`    
        # `yum -y -q install epel-release`
        # `yum -y -q install rpmforge-release`
        # `yum -y -q install tftp-server`
        # `yum -y -q install ntp`
        # `yum -y -q install telnet`
        # `yum -y -q install lm_sensors`
        # `yum -y -q install perl-Config-IniFiles`
        # `yum -y -q install beep`
        # `yum -y -q install freeradius`
        # `service acpid start`
        # `service lm_sensors start`
        # `service ntpd start`


        # ログ情報の先頭に追記
        `echo '*********************** インストール情報 ***********************' > #{@logDir}`
            `date >> #{@logDir}`
            `echo '@zbxSrvIp:#{@zbxSrvIp}' >> #{@logDir}`
            `echo '@mbName:#{@mbName}' >> #{@logDir}`
            `echo '@eth0Ip:#{@eth0Ip}' >> #{@logDir}`
            `echo '@eth0Mask:#{@eth0Mask}' >> #{@logDir}`
            `echo '@eth2Ip:#{@eth2Ip}' >> #{@logDir}`
            `echo '@route:#{@route}' >> #{@logDir}`
            `echo -e "\n\n" >> #{@logDir}`

        # パッケージのインストール
        `echo '*********************** パッケージのインストール ***********************' >> #{@logDir}`
            _logExeCmd('yum -y -q install rubygems ruby-devel')
            _logExeCmd('gem install snmp -v 1.1.1')
            _logExeCmd('gem install json -v 1.8.3')
        `echo -e "\n\n" >> #{@logDir}`
        
        # gitenv
        `echo '*********************** gitenv ***********************' >> #{@logDir}`

            _logExeCmd('\cp -f /var/www/mb_maintenance_ui/public/init_setup/config/.netrc.enc /root/.netrc.enc')
            # _logExeCmd('echo Ch1Qwakare-! > /root/tmp')
            `echo '=== echo Ch1Qwakare-! > /root/tmp ===' >> #{@logDir}`
            `echo Ch1Qwakare-! > /root/tmp`
            `echo -e "\n" >> #{@logDir}`
            _logExeCmd('openssl aes-256-cbc -d -in /root/.netrc.enc -pass file:/root/tmp -out /root/.netrc')

        `echo -e "\n\n" >> #{@logDir}`

        # hostname
        `echo '*********************** hostname ***********************' >> #{@logDir}`

            # _logExeCmd('sed -i -e \'s/HOSTNAME=.*/HOSTNAME=#{@mbName}/g\' /etc/sysconfig/network')
            `echo '=== sed -i -e \'s/HOSTNAME=.*/HOSTNAME=#{@mbName}/g\' /etc/sysconfig/network ===' >> #{@logDir}`
            `sed -i -e \'s/HOSTNAME=.*/HOSTNAME=#{@mbName}/g\' /etc/sysconfig/network >> #{@logDir}`
            `echo -e "\n" >> #{@logDir}`

        `echo -e "\n\n" >> #{@logDir}`

        # lm_sensors
        `echo '*********************** lm_sensors ***********************' >> #{@logDir}`
            _logExeCmd('yes | sensors-detect')
            _logExeCmd('chkconfig lm_sensors on')
        `echo -e "\n\n" >> #{@logDir}`

        # lanip(Eth0)
        `echo '*********************** lanip(Eth0) ***********************' >> #{@logDir}`
            # _logExeCmd('sed -i -e \'s/^IPADDR=.*/IPADDR="#{@eth0Ip}"/g\' /etc/sysconfig/network-scripts/ifcfg-eth0')
            `echo '=== sed -i -e \'s/^IPADDR=.*/IPADDR="#{@eth0Ip}"/g\' /etc/sysconfig/network-scripts/ifcfg-eth0 ===' >> #{@logDir}`
            `sed -i -e \'s/^IPADDR=.*/IPADDR="#{@eth0Ip}"/g\' /etc/sysconfig/network-scripts/ifcfg-eth0 >> #{@logDir}`
            `echo -e "\n" >> #{@logDir}`

            # _logExeCmd('sed -i -e \'s/^NETMASK=.*/NETMASK="#{@eth0Mask}"/g\' /etc/sysconfig/network-scripts/ifcfg-eth0')
            `echo '=== sed -i -e \'s/^NETMASK=.*/NETMASK="#{@eth0Mask}"/g\' /etc/sysconfig/network-scripts/ifcfg-eth0 ===' >> #{@logDir}`
            `sed -i -e \'s/^NETMASK=.*/NETMASK="#{@eth0Mask}"/g\' /etc/sysconfig/network-scripts/ifcfg-eth0 >> #{@logDir}`
            `echo -e "\n" >> #{@logDir}`

        `echo -e "\n\n" >> #{@logDir}`

        # lanip(Eth2)
        `echo '*********************** lanip(Eth2) ***********************' >> #{@logDir}`
            # _logExeCmd('sed -i -e \'s/^IPADDR=.*/IPADDR="#{@eth2Ip}"/g\' /etc/sysconfig/network-scripts/ifcfg-eth2')        
            `echo '=== sed -i -e \'s/^IPADDR=.*/IPADDR="#{@eth2Ip}"/g\' /etc/sysconfig/network-scripts/ifcfg-eth2 ===' >> #{@logDir}`
            `sed -i -e \'s/^IPADDR=.*/IPADDR="#{@eth2Ip}"/g\' /etc/sysconfig/network-scripts/ifcfg-eth2 >> #{@logDir}`
            `echo -e "\n" >> #{@logDir}`

        `echo -e "\n\n" >> #{@logDir}`

        # route
        `echo '*********************** route ***********************' >> #{@logDir}`
            _logExeCmd('rm -f /etc/sysconfig/network-scripts/route-eth0')

            # _logExeCmd('echo #{@route} >> /etc/sysconfig/network-scripts/route-eth0')
            `echo '=== echo #{@route} >> /etc/sysconfig/network-scripts/route-eth0 ===' >> #{@logDir}`
            `echo #{@route} >> /etc/sysconfig/network-scripts/route-eth0`
            `echo -e "\n" >> #{@logDir}`

        # TODO：経路が複数ある場合の処理を追加する。
        `echo -e "\n\n" >> #{@logDir}`

        # rsyslog
        `echo '*********************** rsyslog ***********************' >> #{@logDir}`
            _logExeCmd('mkdir -p /var/log/netmon/router')
            _logExeCmd('mkdir -p /var/log/monitorbox')
            _logExeCmd('\cp -f /var/www/mb_maintenance_ui/public/init_setup/config/etc/rsyslog.conf /etc/rsyslog.conf')
            _logExeCmd('\cp -f /var/www/mb_maintenance_ui/public/init_setup/config/etc/sysconfig/rsyslog /etc/sysconfig/rsyslog')
            _logExeCmd('service rsyslog restart')  
        `echo -e "\n\n" >> #{@logDir}`

        # logrotate
        `echo '*********************** logrotate ***********************' >> #{@logDir}`
            _logExeCmd('mv /etc/cron.daily/logrotate /etc/cron.hourly/logrotate')
            _logExeCmd('\cp -f /var/www/mb_maintenance_ui/public/init_setup/config/etc/logrotate.d/remote /etc/logrotate.d/remote')
            _logExeCmd('\cp -f /var/www/mb_maintenance_ui/public/init_setup/config/etc/logrotate.d/syslog /etc/logrotate.d/syslog')
        `echo -e "\n\n" >> #{@logDir}`

        # service
        `echo '*********************** service ***********************' >> #{@logDir}`
            _logExeCmd('chkconfig xinetd on')
            _logExeCmd('service xinetd start')
            _logExeCmd('mkdir -p /root/tftp')
        `echo -e "\n\n" >> #{@logDir}`

        # ipv6
        `echo '*********************** ipv6 ***********************' >> #{@logDir}`
            _logExeCmd('\cp -f /var/www/mb_maintenance_ui/public/init_setup/config/etc/sysctl.conf /etc/sysctl.conf')
            _logExeCmd('/sbin/sysctl -p')
        `echo -e "\n\n" >> #{@logDir}`

        # sshd
        `echo '*********************** sshd ***********************' >> #{@logDir}`
            # _logExeCmd('sed -i \'s/^#ListenAddress 0.0.0.0/ListenAddress #{@eth2Ip}/\' /etc/ssh/sshd_config')
            `echo '=== sed -i \'s/^#ListenAddress 0.0.0.0/ListenAddress #{@eth2Ip}/\' /etc/ssh/sshd_config ===' >> #{@logDir}`
            `sed -i \'s/^#ListenAddress 0.0.0.0/ListenAddress #{@eth2Ip}/\' /etc/ssh/sshd_config >> #{@logDir}`
            `echo -e "\n" >> #{@logDir}`

            _logExeCmd('service sshd restart')
        `echo -e "\n\n" >> #{@logDir}`

        # ntpd
        `echo '*********************** ntpd ***********************' >> #{@logDir}`
            _logExeCmd('\cp -f /var/www/mb_maintenance_ui/public/init_setup/config/etc/ntp.conf /etc/ntp.conf')
            _logExeCmd('service ntpd restart')
        `echo -e "\n\n" >> #{@logDir}`

        # mibs
        `echo '*********************** mibs ***********************' >> #{@logDir}`
            _logExeCmd('rm -rf /usr/share/netmon/mibs')
            _logExeCmd('git clone https://bitbucket.org/atkksoldev/mibs.git /usr/share/netmon/mibs/')
            _logExeCmd('\cp -f /var/www/mb_maintenance_ui/public/init_setup/config/etc/snmp/snmp.conf /etc/snmp/snmp.conf')
            _logExeCmd('service snmptrapd restart')
        `echo -e "\n\n" >> #{@logDir}`

        # snmptt
        `echo '*********************** snmptt ***********************' >> #{@logDir}`

            _logExeCmd('rm -rf /etc/snmp/snmptt.conf.d')
            _logExeCmd('git clone https://bitbucket.org/atkksoldev/snmpttconfig4netmon.git /etc/snmp/snmptt.conf.d/')

        ### snmptt date time setting
            _logExeCmd('sed -i -e \'s/^date_time_format =.*/date_time_format = %Y\/%m\/%d %H:%M:%S/g\' /etc/snmp/snmptt.ini')

        ### remove old settings
            _logExeCmd('sed -i \'/^\/etc\/snmp\/snmptt.conf$/d\' /etc/snmp/snmptt.ini')
            _logExeCmd('sed -i \'/^\/etc\/snmp\/snmptt.conf.d\/.*\.conf/d\' /etc/snmp/snmptt.ini')

        ### set new settings
            _logExeCmd('sh /etc/snmp/snmptt.conf.d/confinsert.sh')
        
        ### paching snmptt
            _logExeCmd('\cp -f /var/www/mb_maintenance_ui/public/init_setup/config/tmp/disable_unnessesary_msg.patch /tmp/disable_unnessesary_msg.patch')
            # _logExeCmd('patch -uN /usr/local/sbin/snmptt < /tmp/disable_unnessesary_msg.patch')
            `echo '=== patch -uN /usr/local/sbin/snmptt < /tmp/disable_unnessesary_msg.patch ===' >> #{@logDir}`
            `patch -uN /usr/local/sbin/snmptt < /tmp/disable_unnessesary_msg.patch`
            `echo -e "\n" >> #{@logDir}`

            _logExeCmd('rm -f /usr/local/sbin/snmptt.rej')
        `echo -e "\n\n" >> #{@logDir}`

        # snmptt(Deamon Mode)
        `echo '*********************** snmptt(Deamon Mode) ***********************' >> #{@logDir}`
            _logExeCmd('yum  -y -q install epel-release')
            _logExeCmd('yum  -y -q install perl-Config-IniFiles perl-Time-HiRes')
            _logExeCmd('\cp /etc/snmp/snmptt.ini /etc/snmp/snmptt.ini.standalone')
            _logExeCmd('\cp /etc/snmp/snmptrapd.conf /etc/snmp/snmptrapd.conf.standalone')
            _logExeCmd('\cp /etc/sysconfig/snmptrapd /etc/sysconfig/snmptrapd.standalone')
            _logExeCmd('\cp /etc/rc.d/init.d/snmptrapd /etc/rc.d/init.d/snmptrapd.standalone')
            _logExeCmd('mkdir /var/spool/snmptt/')
            _logExeCmd('\cp -f /var/www/mb_maintenance_ui/public/init_setup/config/etc/rc.d/init.d/snmptt /etc/rc.d/init.d/snmptt')
            _logExeCmd('chmod 755 /etc/rc.d/init.d/snmptt')
            _logExeCmd('\cp -f /var/www/mb_maintenance_ui/public/init_setup/config/etc/snmp/snmptt.ini /etc/snmp/snmptt.ini')
            _logExeCmd('chkconfig --add snmptt')
            _logExeCmd('chkconfig --level 2345 snmptt on')
            _logExeCmd('sh /etc/snmp/snmptt.conf.d/confinsert.sh')
            _logExeCmd('service snmptt start')
            _logExeCmd('\cp -f /var/www/mb_maintenance_ui/public/init_setup/config/etc/sysconfig/snmptrapd /etc/sysconfig/snmptrapd')
            _logExeCmd('\cp -f /var/www/mb_maintenance_ui/public/init_setup/config/etc/snmp/snmptrapd.conf /etc/snmp/snmptrapd.conf')
            _logExeCmd('service snmptrapd restart')
        `echo -e "\n\n" >> #{@logDir}`

        # zabbix_agent
        `echo '*********************** zabbix_agent ***********************' >> #{@logDir}`
            _logExeCmd('\cp -f /var/www/mb_maintenance_ui/public/init_setup/config/usr/local/etc/zabbix_agentd.conf /usr/local/etc/zabbix_agentd.conf')

            # _logExeCmd('sed -i -e \'s/^Hostname=.*/Hostname=#{@mbName}_MonitorBox/g\' /usr/local/etc/zabbix_agentd.conf')
            `echo '=== sed -i -e \'s/^Hostname=.*/Hostname=#{@mbName}_MonitorBox/g\' /usr/local/etc/zabbix_agentd.conf ===' >> #{@logDir}`
            `sed -i -e \'s/^Hostname=.*/Hostname=#{@mbName}_MonitorBox/g\' /usr/local/etc/zabbix_agentd.conf >> #{@logDir}`
            `echo -e "\n" >> #{@logDir}`

            # _logExeCmd('sed -i -e \'s/^Server=.*/Server=#{@eth2Ip}/g\' /usr/local/etc/zabbix_agentd.conf')
            `echo '=== sed -i -e \'s/^Server=.*/Server=#{@eth2Ip}/g\' /usr/local/etc/zabbix_agentd.conf ===' >> #{@logDir}`
            `sed -i -e \'s/^Server=.*/Server=#{@eth2Ip}/g\' /usr/local/etc/zabbix_agentd.conf >> #{@logDir}`
            `echo -e "\n" >> #{@logDir}`

            # _logExeCmd('sed -i -e \'s/^ServerActive=.*/ServerActive=#{@eth2Ip}/g\' /usr/local/etc/zabbix_agentd.conf')
            `echo '=== sed -i -e \'s/^ServerActive=.*/ServerActive=#{@eth2Ip}/g\' /usr/local/etc/zabbix_agentd.conf ===' >> #{@logDir}`
            `sed -i -e \'s/^ServerActive=.*/ServerActive=#{@eth2Ip}/g\' /usr/local/etc/zabbix_agentd.conf >> #{@logDir}`
            `echo -e "\n" >> #{@logDir}`

            _logExeCmd('sed -i \'/^ListenIPs*=.*/d\' /usr/local/etc/zabbix_agentd.conf')

            # _logExeCmd('sed -i \'/# ListenIP=0.0.0.0/a\\ListenIP=#{@eth2Ip}\' /usr/local/etc/zabbix_agentd.conf')
            `echo '=== sed -i \'/# ListenIP=0.0.0.0/a\\ListenIP=#{@eth2Ip}\' /usr/local/etc/zabbix_agentd.conf ===' >> #{@logDir}`
            `sed -i \'/# ListenIP=0.0.0.0/a\\ListenIP=#{@eth2Ip}\' /usr/local/etc/zabbix_agentd.conf >> #{@logDir}`
            `echo -e "\n" >> #{@logDir}`

            _logExeCmd('\cp -f /var/www/mb_maintenance_ui/public/init_setup/config/usr/local/etc/zabbix_agentd.conf.d/temperature.conf /usr/local/etc/zabbix_agentd.conf.d/temperature.conf')
            _logExeCmd('service zabbix_agentd restart')
        `echo -e "\n\n" >> #{@logDir}`

        # zabbix_proxy
        `echo '*********************** zabbix_proxy ***********************' >> #{@logDir}`
            _logExeCmd('\cp -f /var/www/mb_maintenance_ui/public/init_setup/config/usr/local/etc/zabbix_proxy.conf /usr/local/etc/zabbix_proxy.conf')

            # _logExeCmd('sed -i -e \'s/^Server=.*/Server=#{@zbxSrvIp}/g\' /usr/local/etc/zabbix_proxy.conf')
            `echo '=== sed -i -e \'s/^Server=.*/Server=#{@zbxSrvIp}/g\' /usr/local/etc/zabbix_proxy.conf ===' >> #{@logDir}`
            `sed -i -e \'s/^Server=.*/Server=#{@zbxSrvIp}/g\' /usr/local/etc/zabbix_proxy.conf >> #{@logDir}`
            `echo -e "\n" >> #{@logDir}`

            # _logExeCmd('sed -i -e \'s/^Hostname=.*/Hostname=#{@mbName}/g\' /usr/local/etc/zabbix_proxy.conf')
            `echo '=== sed -i -e \'s/^Hostname=.*/Hostname=#{@mbName}/g\' /usr/local/etc/zabbix_proxy.conf ===' >> #{@logDir}`
            `sed -i -e \'s/^Hostname=.*/Hostname=#{@mbName}/g\' /usr/local/etc/zabbix_proxy.conf >> #{@logDir}`
            `echo -e "\n" >> #{@logDir}`

            _logExeCmd('sed -i -e \'s/^Timeout=.*/Timeout=10/g\' /usr/local/etc/zabbix_proxy.conf')
            _logExeCmd('service zabbix_proxy restart')
        `echo -e "\n\n" >> #{@logDir}`

        # zbx_extscript
        `echo '*********************** zbx_extscript ***********************' >> #{@logDir}`
            _logExeCmd('rm -rf /usr/local/etc/zabbix/externalscripts')
            _logExeCmd('git clone https://bitbucket.org/atkksoldev/zbx-externalscripts.git /usr/local/etc/zabbix/externalscripts/')
        `echo -e "\n\n" >> #{@logDir}`

        # 後処理
        `echo '*********************** 後処理 ***********************' >> #{@logDir}`

            _logExeCmd('rm -f /root/tmp')
            _logExeCmd('rm -f /root/.netrc')
            _logExeCmd('rm -f /root/.netrc.enc')
            _logExeCmd('reboot')
            # _logExeCmd('shutdown -r +1')

        filePath = Rails.root.join('public', 'initsetup.log')
        send_file(filePath)

    end

    private

    def _logExeCmd(cmd)

        # Log File 保存先と保存形式の指定
        logDir = @logDir
        logSetting = @logSetting

        # コマンドの実行
        `echo '=== #{cmd} ===' >> #{logDir}`
        `#{cmd} #{logSetting}`
        `echo -e "\n" >> #{logDir}`
    end


end
