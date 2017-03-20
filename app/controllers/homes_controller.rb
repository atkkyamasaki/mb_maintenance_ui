# Home
# Author:: YAMASAKI, Takefumi
# ダッシュボードに稼動マシンの状態を表示するためのクラス
class HomesController < ApplicationController

    def show
        # # facter でのデータ取得を中止
        # @hostName = _getServerInfo["hostname"]
        # @kernelRelease = _getServerInfo["kernelrelease"]
        # @upTime = _getServerInfo["uptime"]
        # @upTimeHour = _getServerInfo["uptime_hours"]
        # @upTimeSeconds = _getServerInfo["uptime_seconds"]
        # @ipEth0 = _getServerInfo["ipaddress_eth0"]
        # @ipEth2 = _getServerInfo["ipaddress_eth2"]
        # @cpuIdle = _getServerInfo["cpu_idle"]
        # @memSize = _getServerInfo["memorysize"]
        # @memFree = _getServerInfo["memoryfree"]
        # @swapSize = _getServerInfo["swapsize"]
        # @swapFree = _getServerInfo["swapfree"]
        # @diskSize = _getServerInfo["df_sda3_size"]
        # @diskFree = _getServerInfo["df_sda3_avail"]
        # logInfo = _getServerInfo["var_log_messages_tail100"]

        # # Linux コマンドでデータ収集
        @hostName = %x(hostname)
        @kernelRelease = %x(uname -r)
        @upTimeSeconds = %x(cat /proc/uptime | awk '{print $1}' | tr -d '\n' | sed s/\.[0-9,]*$//g)
        @upTimeHour = (@upTimeSeconds.to_i / 3600)
        # @upTime = %x(uptime | awk '{ print $3 $4 }' | tr -d ',\n')
        @ipEth0 = %x(grep -E ^IPADDR /etc/sysconfig/network-scripts/ifcfg-eth0 | sed -e "s/IPADDR=//g" | sed -e 's/"//g' | tr -d '\n')
        @ipEth2 = %x(grep -E ^IPADDR /etc/sysconfig/network-scripts/ifcfg-eth2 | sed -e "s/IPADDR=//g" | sed -e 's/"//g' | tr -d '\n')
        @cpuIdle = %x(mpstat 1 1 | sed -n '4,4p' | awk '{ print $11 }' | tr -d '\n')
        @memSize = %x(free -m | sed -n '2,2p' | awk '{ print $2 }' | tr -d '\n') + 'MB'
        @memFree = %x(free -m | sed -n '2,2p' | awk '{ print $4 }' | tr -d '\n') + 'MB'
        @swapSize = %x(free -m | sed -n '4,4p' | awk '{ print $2 }' | tr -d '\n') + 'MB'
        @swapFree = %x(free -m | sed -n '4,4p' | awk '{ print $4 }' | tr -d '\n') + 'MB'
        @diskSize = %x(df -m /dev/sda3 | sed -n '2p' |  awk '{ print $2 }' | tr -d '\n') + 'MB'
        @diskFree = %x(df -m /dev/sda3 | sed -n '2p' |  awk '{ print $4 }' | tr -d '\n') + 'MB'
        serviceZbxProxy = %x(service zabbix_proxy status)
        serviceZbxAgent = %x(service zabbix_agentd status)
        pingZbxServer = `ping -w 1 -n -c 1 150.87.1.103 | sed -n '2p'`

            if pingZbxServer.include?('time') 
                # Ping 成功時
                @pingZbxServer = 'OK'
            else
                # Ping 失敗時の結果を配列で返す
                @pingZbxServer = 'NG'
            end

        servicePgsql = %x(service pgsql status)
        serviceSnmptt = %x(service snmptt status)
        @snmpttMode =  %x(grep -E ^mode /etc/snmp/snmptt.ini | sed -e "s/mode.=.//g" | sed -e 's/"//g' | tr -d '\n')
        serviceSnmptrapd = %x(service snmptrapd status)
        serviceNtpd = %x(service ntpd status)
        serviceRsyslog = %x(service rsyslog status)
        @ntpServer = %x(ntpq -p | grep ^* | awk '{ print $1 }' | sed "s/*//g" | tr -d '\n')
        logInfo = %x(tail -100 /var/log/messages)

        # cpu、memory、disk グラフ用の処理
        cpuUse = 100 - @cpuIdle.to_f
        memUse = _convertBytesUnits(@memSize).to_f - _convertBytesUnits(@memFree).to_f
        memUsePercent = (memUse.to_f / (memUse.to_f + _convertBytesUnits(@memFree).to_f)) *100
        memFreePercent = (_convertBytesUnits(@memFree).to_f / (memUse.to_f + _convertBytesUnits(@memFree).to_f)) *100
        diskUse = @diskSize.delete("^0-9").to_f - @diskFree.delete("^0-9").to_f 
        diskUsePercent = (diskUse.to_f / (diskUse.to_f + @diskFree.delete("^0-9").to_f)) * 100
        diskFreePercent = (@diskFree.delete("^0-9").to_f / (diskUse.to_f + @diskFree.delete("^0-9").to_f)) * 100

        # グラフ用の配列作成
        @chart_data_cpu = [['Free', @cpuIdle.to_f.round(1)], ['Usage', cpuUse.round(1)]]
        @chart_data_memory = [['Free', memFreePercent.round(1)], ['Usage', memUsePercent.round(1)]]
        @chart_data_disk = [['Free', diskFreePercent.round(1)], ['Usage', diskUsePercent.round(1)]]
        # @chart_data_cpu = [['Free', 99], ['Usage', 1]]
        @chart_data = [@chart_data_cpu,@chart_data_memory,@chart_data_disk,@cpuIdle,@memSize,@memFree,@swapSize,@swapFree,@diskSize,@diskFree,@memSize,@memFree,@swapSize,@swapFree,@diskSize,@diskFree]

        # サービス関連の処理
        @serviceZbxProxy = _isServiceRunning(serviceZbxProxy)
        @serviceZbxAgent = _isServiceRunning(serviceZbxAgent)
        @servicePgsql = _isServiceRunning(servicePgsql)
        @serviceSnmptt = _isServiceRunning(serviceSnmptt)
        @serviceSnmptrapd = _isServiceRunning(serviceSnmptrapd)
        @serviceNtpd = _isServiceRunning(serviceNtpd)
        @serviceRsyslog = _isServiceRunning(serviceRsyslog)

        # ログの処理
        logs = logInfo.rstrip.split(/\r?\n/).map {|line| line.chomp}

        logsSort = Array.new
        logs.reverse_each do |var|
            logsSort.push(var)
        end

        @logsSortAfter = Kaminari.paginate_array(logsSort).page(params[:page]).per(10)

        respond_to do |format|
            format.html
            format.json {render :json => @chart_data}
        end
     end

    private
    def _convertBytesUnits(num)
        if (num.include?("G"))
            result = num.delete("^0-9").to_i.gigabytes
            return result
        elsif (num.include?("M"))
            result = num.delete("^0-9").to_i.megabytes
            return result
        elsif (num.include?("K"))
            result = num.delete("^0-9").to_i.kilobytes
            return result
        end
    end

    def _isServiceRunning(service)
        if (service.include?("pid") || service.include?("PID"))
            return 'Running'
        else
            return 'Stop'
        end
    end


    # facter を利用すると Cache されて値がうまく更新できないので利用取りやめ
    # def _getServerInfo()
    #     require 'facter'
    #     # require_dependency 'facter'
    #     # load '/usr/local/rbenv/versions/2.2.5/lib/ruby/gems/2.2.0/gems/facter-2.4.6/lib/facter.rb'
    #     return Hash[

    #         # 参考URL
    #         # <http://interu.hatenablog.com/entry/20090130/1233244319>

    #         "hostname" => Facter.value(:hostname),
    #         "uptime" => Facter.value(:uptime),
    #         "uptime_days" => Facter.value(:uptime_days),
    #         "uptime_hours" => Facter.value(:uptime_hours),
    #         "uptime_seconds" => Facter.value(:uptime_seconds),
    #         "system_uptime" => Facter.value(:system_uptime),
    #         "interfaces" => Facter.value(:interfaces),
    #         "ipaddress_eth0" => Facter.value(:ipaddress_eth0),
    #         "ipaddress_eth2" => Facter.value(:ipaddress_eth2),
    #         "netmask_eth0" => Facter.value(:netmask_eth0),
    #         "netmask_eth2" => Facter.value(:netmask_eth2),
    #         "macaddress_eth0" => Facter.value(:macaddress_eth0),
    #         "macaddress_eth2" => Facter.value(:macaddress_eth2),
    #         "processor0" => Facter.value(:processor0),
    #         "processorcount" => Facter.value(:processorcount),
    #         "memoryfree" => Facter.value(:memoryfree),
    #         "memorysize" => Facter.value(:memorysize),
    #         "swapfree" => Facter.value(:swapfree),
    #         "swapsize" => Facter.value(:swapsize),
    #         "blockdevices" => Facter.value(:blockdevices),
    #         "blockdevice_sda_size" => Facter.value(:blockdevice_sda_size),
    #         "blockdevice_sda_vendor" => Facter.value(:blockdevice_sda_vendor),
    #         "blockdevice_sda_model" => Facter.value(:blockdevice_sda_model),
    #         "filesystems" => Facter.value(:filesystems),
    #         "partitions" => Facter.value(:partitions),
    #         "operatingsystem" => Facter.value(:operatingsystem),
    #         "operatingsystemrelease" => Facter.value(:operatingsystemrelease),
    #         "kernel" => Facter.value(:kernel),
    #         "kernelrelease" => Facter.value(:kernelrelease),
    #         "kernelversion" => Facter.value(:kernelversion),

    #         # Custom Facter
    #         "cpu_idle" => Facter.value(:cpu_idle),
    #         "df_sda3_size" => Facter.value(:df_sda3_size),
    #         "df_sda3_used" => Facter.value(:df_sda3_used),
    #         "df_sda3_avail" => Facter.value(:df_sda3_avail),
    #         "df_sda3_percent" => Facter.value(:df_sda3_percent),
    #         "var_log_messages_tail100" => Facter.value(:var_log_messages_tail100),
    #     ]

    # end
end
