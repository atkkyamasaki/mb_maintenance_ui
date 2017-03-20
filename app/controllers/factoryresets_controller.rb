class FactoryresetsController < ApplicationController

    def show

        @judges = [
            ['ホスト名', %x(hostname).chomp, 'localhost.localdomain'],
            ['Eth0 IP', %x(grep -E ^IPADDR /etc/sysconfig/network-scripts/ifcfg-eth0 | sed -e "s/IPADDR=//g" | sed -e 's/"//g' | tr -d '\n').chomp, '192.168.1.1'],
            ['Zabbix Proxy 設定', %x(grep ^Server= /usr/local/etc/zabbix_proxy.conf).chomp, 'Server=127.0.0.1'],
            ['Zabbix Agent 設定', %x(grep ^Server= /usr/local/etc/zabbix_agentd.conf).chomp, 'Server=127.0.0.1']
        ] 

    end

    def update

        # IBS 社初期化スクリプト対応外の初期化
        `\cp -f /var/www/mb_maintenance_ui/public/factoryreset/rsyslog /etc/sysconfig/rsyslog`
        `\cp -f /var/www/mb_maintenance_ui/public/factoryreset/syslog /etc/logrotate.d/syslog`
        `\cp -f /var/www/mb_maintenance_ui/public/factoryreset/snmptrapd /etc/sysconfig/snmptrapd`
        `\cp -f /var/www/mb_maintenance_ui/public/factoryreset/snmptrapd.conf /etc/snmp/snmptrapd.conf`
        `\cp -f /var/www/mb_maintenance_ui/public/factoryreset/sshd_config /etc/ssh/sshd_config`
        `\cp -f /var/www/mb_maintenance_ui/public/factoryreset/sysctl.conf /etc/sysctl.conf`
        `\cp -f /var/www/mb_maintenance_ui/public/factoryreset/.bash_profile /root/.bash_profile`
        `rm -f /etc/rc.d/init.d/snmptt`
        `rm -f /etc/sysconfig/network-scripts/route-eth0`
        `rm -rf /var/log/netmon`
        `rm -rf /var/log/monitorbox`
        `rm -rf /var/log/operation-log`
        `rm -rf /usr/share/netmon/mibs`
        `rm -rf /etc/snmp/snmptt.conf.d`
        `rm -rf /usr/local/etc/zabbix/externalscripts`

        # 初期化スクリプトのコピー
        `\cp -f /var/www/mb_maintenance_ui/public/configure.xz /tmp/configure.xz`    

        # 初期化の実行
        `tar PJxf /tmp/configure.xz`
        `/opt/obzerver-proxy/utils/configure.sh factory-default`    
        `shutdown -r now`    

        redirect_to "/maintenance/factoryreset"

    end


end
