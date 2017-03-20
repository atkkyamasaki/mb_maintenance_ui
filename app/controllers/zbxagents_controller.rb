class ZbxagentsController < ApplicationController
include Configurecommon

    def show

        # zabbix_agentd.conf ファイルから設定情報を参照しハッシュに格納
        zbxConfGet = %x(grep -v -e '^\s*#' -e '^\s*$' /usr/local/etc/zabbix_agentd.conf).split("\n")
        
        @zbxConf = {}
        zbxConfGet.each{|var|
            tmp = /=/.match(var)
            @zbxConf.store(tmp.pre_match, tmp.post_match)
        }

        # Default 設定は明記されていないので、上記ハッシュになければ自動作成（※ 必須設定は除外）
        # 参考URL <https://www.zabbix.com/documentation/2.2/jp/manual/appendix/config/zabbix_agentd>
        zbxDefaultConf = Hash[
            "Alias",nil,
            "AllowRoot",0,
            "BufferSend",5,
            "BufferSize",100,
            "DebugLevel",3,
            "EnableRemoteCommands",0,
            "HostMetadata",nil,
            "HostMetadataItem",nil,
            "Hostname",nil,
            "HostnameItem","system.hostname",
            "Include",nil,
            "ListenIP","0.0.0.0",
            "ListenPort",10050,
            "LoadModule",nil,
            "LoadModulePath",nil,
            "LogFile",nil,
            "LogFileSize",1,
            "LogRemoteCommands",0,
            "MaxLinesPerSecond",100,
            "PidFile","/tmp/zabbix_agentd.pid",
            "RefreshActiveChecks",120,
            "Server",nil,
            "ServerActive",nil,
            "SourceIP",nil,
            "StartAgents",3,
            "Timeout",3,
            "UnsafeUserParameters",0,
            "UserParameter",nil,
        ]

        zbxDefaultConf.each do |key, value|
            _defaultConfWrite(@zbxConf, key, value)
        end
    end


    def update

        # 現在の Config File をバックアップ
        `mkdir /usr/local/etc/archive`
        date = `date +%Y%m%d%H%M`
        `cp /usr/local/etc/zabbix_agentd.conf /usr/local/etc/archive/zabbix_agentd.conf_#{date}`

        # patch で取得した内容を更新し、サービス再起動
        params.each do |key, value|
            if ( key != 'authenticity_token' && key != 'commit' && key != '_method' && key != 'utf8' )
                _confChangeCmd('/usr/local/etc/zabbix_agentd.conf', key, value)
            end
        end

        %x(service zabbix_agentd restart)

        redirect_to "/configuration/zbxagent"
    end

end
