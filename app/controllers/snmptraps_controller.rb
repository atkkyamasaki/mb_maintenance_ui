class SnmptrapsController < ApplicationController

    # 外部からの POST 処理を受け付けられるよう CSRF を向こうかする
    # <http://hokaccha.hatenablog.com/entry/20130730/1375147564>
    protect_from_forgery with: :null_session

    def show

        # ホスト一覧表示用
        @hosts = Host.all

        # ログから SNMP TRAP 関連の必要情報のみ取得
        logInfos = %x(tail -50 /var/log/messages | grep ZBXTRAP)

        logs = []
        logInfos.each_line do |line|
            log = []
            log.push(line.chomp.split(/[[:space:]]+/, 10)[0])
            log.push(line.chomp.split(/[[:space:]]+/, 10)[1])
            log.push(line.chomp.split(/[[:space:]]+/, 10)[2])

            ip = line.chomp.split(/[[:space:]]+/, 10)[6]
            host = Host.select(:ip).where(ip: ip)

            test = @hosts.select(:hostname).where(ip: ip)
            test.each do |value|
                host = value.hostname
            end

            log.push(host)
            log.push(ip)

            log.push(line.chomp.split(/[[:space:]]+/, 10)[7])
            log.push(line.chomp.split(/[[:space:]]+/, 10)[9])
            logs.push(log)
        end

        # logs = logInfos.rstrip.split(/\r?\n/).map {|line| line.chomp.split(/[[:space:]]/, 10)}

        @results = []
        logs.reverse_each do |var|
            @results.push(var)
        end

        respond_to do |format|
            format.html
            format.json {render :json => @results}
        end

    end

    # Login 認証の無効化
    def use_before_action?
        false
    end

end
