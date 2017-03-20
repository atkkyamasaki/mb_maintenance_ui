class PingsController < ApplicationController

    # 外部からの POST 処理を受け付けられるよう CSRF を向こうかする
    # <http://hokaccha.hatenablog.com/entry/20130730/1375147564>
    protect_from_forgery with: :null_session

    def show

        # ホスト一覧表示用
        @hosts = Host.all

        # Ping 統計結果表示用
        @results = []
        value = Host.all
        value.each do |host|
            array = []

            # Host名
            array.push(host.hostname)

            # IP
            array.push(host.ip)

            # 実施回数
            allTotal = host.pings.count
            array.push(allTotal)

            # NG 回数
            ngTotal = host.pings.where(status: '0').count
            array.push(ngTotal)

            # 失敗率
            if ngTotal === 0 then
                ngPercent = '0%'
            else
                ngPercent = (ngTotal.to_f / allTotal * 100).round(1).to_s + '%'
            end
            array.push(ngPercent)

            # 最小時間
            array.push(host.pings.order(response: :asc).limit(1).pluck(:response))

            # 最大時間
            array.push(host.pings.order(response: :desc).limit(1).pluck(:response))

            # 平均時間
            array.push(host.pings.average(:response).to_f.round(2))

            # 直近3回の実施結果
            array.push(host.pings.order(updated_at: :desc).limit(3).pluck(:status))

            # Host ID （※ Hosts テーブル上での ID）
            array.push(host.id)

            @results.push(array)
        end

        # Host 数に応じてAjax(get)間隔を調整する
        # (台数が多い場合は10秒間隔)
        case @hosts.length
        when (0..10) then @hosts_length = 5000
        when (11..20) then @hosts_length = 5000
        when (21..30) then @hosts_length = 5000
        when (31..60) then @hosts_length = 5000
        when (61..Float::INFINITY) then @hosts_length = 10000
        # when (61..120) then sleep(0.5)
        # when (121..Float::INFINITY) then sleep(0.25)
        else @hosts_length = 5000
        end

        respond_to do |format|
            format.html
            format.json {render :json => @results}
        end
    end

    def create

        # 対象 Host に Ping を実行し、結果をデータベースに書き込む
        value = Host.all
        value.each do |host|
   
            pingResult = _pingResultGet(host.ip)

            add = Ping.new
                add.host_id = host.id
                add.status = pingResult[0]
                add.response = pingResult[1]
            add.save!

            # Host 数に応じてsleep間隔を調整する
            # (1分で1周が目安)
            case value.length
            when (0..10) then sleep(6)
            when (11..20) then sleep(3)
            when (21..30) then sleep(2)
            when (31..60) then sleep(1)
            when (61..Float::INFINITY) then sleep(0.5)
            # when (61..120) then sleep(0.5)
            # when (121..Float::INFINITY) then sleep(0.25)
            else sleep(0.5)
            end

        end

        @reply = ['success']

        respond_to do |format|
            format.json {render :json => @reply}
        end


    end

    def destroy

        Ping.delete_all

        @reply = ['success']

        respond_to do |format|
            format.json {render :json => @reply}
        end

    end


    private 

    def _pingResultGet(host)

        msg = `ping -w 1 -n -c 1 #{host} | sed -n '2p'`

        if msg.include?('time') 

            # Ping 成功時の結果を配列で返す
            response = msg.split(/[[:space:]]/)[6].delete("time=")
            array = []
            array.push(1)
            array.push(response)
            return array

        else

            # Ping 失敗時の結果を配列で返す
            array = []
            array.push(0)
            array.push(nil)
            return array

        end

    end

    # Login 認証の無効化
    def use_before_action?
        false
    end

end
