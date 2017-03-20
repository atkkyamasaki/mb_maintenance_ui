class HostsController < ApplicationController

    def show

        # ホスト一覧表示用
        @hosts = Host.all

    end

    def create
        require 'kconv'
        require 'csv'

        file = params[:uppic]

        if file.nil?
            msg = 'ファイルを選択してください'
        else 
            
            name = file.original_filename
            if !['.csv'].include?(File.extname(name).downcase)
                msg = 'アップロードできるのはCSV Fileのみ'
            elsif file.size > 10.megabyte
                msg = 'アップロードは10メガバイトまで'
            else
                name = 'hosts.csv'
                File.open("/var/www/mb_maintenance_ui/public/host_csv/#{name}", 'wb') { |f| f.write(file.read) }
                msg = "#{name.toutf8}のアップロードに成功しました"
            end
        end

        if msg.include?('成功')

            # 現在のデータベース情報を削除
            Host.delete_all

            # ホスト一覧の CSV File を読み込む
            # csv_data = CSV.read('/var/www/mb_maintenance_ui/public/host_csv/hosts.csv', headers: true)
            csv_data = CSV.read('/var/www/mb_maintenance_ui/public/host_csv/hosts.csv')

            csv_data.each do |data|

                add = Host.new
                    add.hostname = data[0]
                    add.ip = data[1]
                add.save!

            end
            redirect_to :controller => 'hosts', :action => 'show'

        else
            render :text => msg
        end


    end

    def new



    end


end
