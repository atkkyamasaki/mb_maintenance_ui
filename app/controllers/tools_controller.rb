class ToolsController < ApplicationController

    def show 

        toolsId = params[:key]
        @result = ''

        case toolsId
        when 'config_export' then

            %x(tar czfP /var/www/mb_maintenance_ui/public/mb_data.tar /etc/logrotate.conf /etc/ntp.conf /etc/resolv.conf /etc/rsyslog.conf /etc/sysctl.conf /etc/cron.daily/hwclock /etc/cron.hourly/logrotate /etc/logrotate.d/remote /etc/logrotate.d/syslog /etc/rc.d/init.d/snmptt /etc/snmp/snmp.conf /etc/snmp/snmptrapd.conf /etc/snmp/snmptrapd.conf.standalone /etc/snmp/snmptt.ini /etc/snmp/snmptt.ini.standalone /etc/sysconfig/network /etc/sysconfig/rsyslog /etc/sysconfig/snmptrapd /etc/sysconfig/snmptrapd.standalone /etc/sysconfig/network-scripts/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-eth2 /etc/sysconfig/network-scripts/route-eth0 /etc/sysconfig/network-scripts/route-eth2 /etc/ssh/sshd_config /etc/xinetd.d/tftp /usr/local/sbin/snmptt /usr/local/etc/zabbix_proxy.conf /usr/local/etc/zabbix_agentd.conf /usr/local/etc/zabbix_agentd.conf.d/temperature.conf)

            filePath = Rails.root.join('public', 'mb_data.tar')
            send_file(filePath)

        when 'config_import' then

        when 'restart_zbxproxy' then
            %x(service zabbix_proxy restart)
            @result = 'Success!'
            render :json => @result

        when 'restart_zbxagent' then
            %x(service zabbix_agentd restart)
            @result = 'Success!'
            render :json => @result

        when 'restart_pgsql' then
            %x(service pgsql restart)
            @result = 'Success!'
            render :json => @result

        when 'restart_snmptt' then
            %x(service snmptt restart)
            @result = 'Success!'
            render :json => @result

        when 'restart_snmptrapd' then
            %x(service snmptrapd restart)
            @result = 'Success!'
            render :json => @result

        when 'restart_ntpd' then
            %x(service ntpd restart)
            @result = 'Success!'
            render :json => @result

        when 'restart_rsyslogd' then
            %x(service rsyslog restart)
            @result = 'Success!'
            render :json => @result

        when 'mb_reboot' then
            %x(reboot)
            @result = 'Success! Reboot...'
            render :json => @result

        when 'mib_snmptt_update' then
            %x(cp -f /var/www/mb_maintenance_ui/public/init_setup/config/.netrc.enc /root/.netrc.enc)
            %x(echo Ch1Qwakare-! > /root/tmp)
            %x(openssl aes-256-cbc -d -in /root/.netrc.enc -pass file:/root/tmp -out /root/.netrc)
            %x(rm -rf /usr/share/netmon/mibs)
            %x(git clone https://bitbucket.org/atkksoldev/mibs.git /usr/share/netmon/mibs/)
            %x(rm -rf /etc/snmp/snmptt.conf.d)
            %x(git clone https://bitbucket.org/atkksoldev/snmpttconfig4netmon.git /etc/snmp/snmptt.conf.d/)
            %x(rm -f /root/tmp)
            %x(rm -f /root/.netrc)
            %x(rm -f /root/.netrc.enc)
            %x(sh /etc/snmp/snmptt.conf.d/confinsert.sh)
            %x(service snmptt restart)
            @result = 'Success!'
            render :json => @result

        else
            @result = '内部処理に意図せぬ問題が発生しました。処理は正しく完了していませんので調査ください。'
            render :json => @result

        end
    end


    def create

        require 'kconv'
        require 'csv'

        file = params[:uppic]

        if file.nil?
            msg = 'ファイルを選択してください。'
        else 
            
            name = file.original_filename
            if !['.tar'].include?(File.extname(name).downcase)
                msg = 'アップロードできるのはtar Fileのみです。'
            elsif file.size > 10.megabyte
                msg = 'アップロードは10メガバイトまでです。'
            else
                name = 'mb_data.tar'
                File.open("/var/www/mb_maintenance_ui/public/#{name}", 'wb') { |f| f.write(file.read) }
                msg = "#{name.toutf8}のアップロードに成功しました"
            end
        end

        if msg.include?('成功')
            %x(tar xvfP /var/www/mb_maintenance_ui/public/mb_data.tar)
            %x(shutdown -r +1)
            redirect_to( :back )
        else

            render :text => msg
        end

    end

end
