class ZbxproxiesController < ApplicationController

include Configurecommon

    def show

        # zabbix_proxy.conf ファイルから設定情報を参照しハッシュに格納
        zbxConfGet = %x(grep -v -e '^\s*#' -e '^\s*$' /usr/local/etc/zabbix_proxy.conf).split("\n")
        
        @zbxConf = {}
        zbxConfGet.each{|var|
            tmp = /=/.match(var)
            @zbxConf.store(tmp.pre_match, tmp.post_match)
        }

        # Default 設定は明記されていないので、上記ハッシュになければ自動作成（※ 必須設定は除外）
        # 参考URL <https://www.zabbix.com/documentation/2.2/jp/manual/appendix/config/zabbix_proxy>
        zbxDefaultConf = Hash[
            "AllowRoot",0,
            "CacheSize","8M",
            "ConfigFrequency",3600,
            "DBHost","localhost",
            "DBPassword",nil,
            "DBSchema",nil,
            "DBSocket",3306,
            "DBUser",nil,
            "DataSenderFrequency",1,
            "DebugLevel",3,
            "ExternalScripts","/usr/local/share/zabbix/externalscripts",
            "Fping6Location","/usr/sbin/fping6",
            "FpingLocation","/usr/sbin/fping",
            "HistoryCacheSize","8M",
            "HistoryTextCacheSize","16M",
            "Hostname",nil,
            "HostnameItem","system.hostname",
            "HousekeepingFrequency",1,
            "Include",nil,
            "JavaGateway",nil,
            "JavaGatewayPort",10052,
            "ListenIP","0.0.0.0",
            "ListenPort",10051,
            "LoadModule",nil,
            "LoadModulePath",nil,
            "LogFile",nil,
            "LogFileSize",1,
            "LogSlowQueries",0,
            "PidFile","/tmp/zabbix_proxy.pid",
            "ProxyLocalBuffer",0,
            "ProxyOfflineBuffer",1,
            "ServerPort",10051,
            "SNMPTrapperFile","/tmp/zabbix_traps.tmp",
            "SourceIP",nil,
            "SSHKeyLocation",nil,
            "StartDBSyncers",4,
            "StartHTTPPollers",1,
            "StartIPMIPollers",0,
            "StartJavaPollers",0,
            "StartPingers",1,
            "StartPollersUnreachable",1,
            "StartPollers",5,
            "StartSNMPTrapper",0,
            "StartTrappers",5,
            "StartVMwareCollectors",0,
            "Timeout",3,
            "TmpDir","/tmp",
            "UnavailableDelay",60,
            "UnreachableDelay",15,
            "UnreachablePeriod",45,
            "VMwareCacheSize","8M",
            "VMwareFrequency",60,
        ]

        zbxDefaultConf.each do |key, value|
            _defaultConfWrite(@zbxConf, key, value)
        end
    end


    def update

        # 現在の Config File をバックアップ
        `mkdir /usr/local/etc/archive`
        date = `date +%Y%m%d%H%M`
        `cp /usr/local/etc/zabbix_proxy.conf /usr/local/etc/archive/zabbix_proxy.conf_#{date}`

        # patch で取得した内容を更新し、サービス再起動
        params.each do |key, value|
            if ( key != 'authenticity_token' && key != 'commit' && key != '_method' && key != 'utf8' )
                _confChangeCmd('/usr/local/etc/zabbix_proxy.conf', key, value)
            end
        end

        %x(service zabbix_proxy restart)

        # @test = %x(cat /root/zabbix_proxy.conf | grep -E ^AllowRoot).empty?
        # render :text => @test

        redirect_to "/configuration/zbxproxy"
    end

end
