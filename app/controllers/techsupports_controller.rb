class TechsupportsController < ApplicationController

    def show
    end

    def new

        cookies[:exported] = { value: 'yes', expires: 1.minutes.from_now  }

        # 取得ファイルの作成
        @logDir = '/var/www/mb_maintenance_ui/public/tech-support.log'

        # File の初期化
        %x(cp -f /dev/null #{@logDir})

        # 情報取得コマンド実行
        %x(echo "*********************** Basic Info ***********************" >> #{@logDir})
        %x(echo -e "================= date =================" >> #{@logDir})
        %x(date >> #{@logDir})
        %x(echo -e "\n\n" >> #{@logDir})

        %x(echo -e "================= hostname =================" >> #{@logDir})
        %x(hostname >> #{@logDir})
        %x(echo -e "\n\n" >> #{@logDir})

        %x(echo -e "================= uptime =================" >> #{@logDir})
        %x(uptime >> #{@logDir})
        %x(echo -e "\n\n" >> #{@logDir})


        %x(echo "*********************** CPU Info ***********************" >> #{@logDir})
        %x(echo -e "================= vmstat =================" >> #{@logDir})
        %x(vmstat >> #{@logDir})
        %x(echo -e "\n\n" >> #{@logDir})

        %x(echo -e "================= sar =================" >> #{@logDir})
        %x(sar -u -P ALL >> #{@logDir})
        %x(echo -e "\n\n" >> #{@logDir})


        %x(echo "*********************** Memory Info ***********************" >> #{@logDir})
        %x(echo -e "================= free =================" >> #{@logDir})
        %x(free -m >> #{@logDir})
        %x(echo -e "\n\n" >> #{@logDir})


        %x(echo "*********************** Disk Info ***********************" >> #{@logDir})
        %x(echo -e "================= df =================" >> #{@logDir})
        %x(df -h >> #{@logDir})
        %x(echo -e "\n\n" >> #{@logDir})


        %x(echo "*********************** Service/Process Info ***********************" >> #{@logDir})
        %x(echo -e "================= top =================" >> #{@logDir})
        %x(top -b -n 10 -d 1 >> #{@logDir})
        %x(echo -e "\n\n" >> #{@logDir})

        %x(echo -e "================= netstat -an =================" >> #{@logDir})
        %x(netstat -an >> #{@logDir})
        %x(echo -e "\n\n" >> #{@logDir})

        %x(echo -e "================= ps =================" >> #{@logDir})
        %x(ps -aux >> #{@logDir})
        %x(echo -e "\n\n" >> #{@logDir})


        %x(echo "*********************** Packet Info ***********************" >> #{@logDir})
        %x(echo -e "================= netstat -i =================" >> #{@logDir})
        %x(netstat -i >> #{@logDir})
        %x(echo -e "\n\n" >> #{@logDir})

        %x(echo -e "================= netstat -s =================" >> #{@logDir})
        %x(netstat -s >> #{@logDir})
        %x(echo -e "\n\n" >> #{@logDir})


        %x(echo "*********************** Log Info ***********************" >> #{@logDir})
        %x(echo -e "================= messages =================" >> #{@logDir})
        %x(tail -300 /var/log/messages >> #{@logDir})
        %x(echo -e "\n\n" >> #{@logDir})

        %x(echo -e "================= snmptt.log =================" >> #{@logDir})
        %x(tail -300 /var/log/snmptt/snmptt.log >> #{@logDir})
        %x(echo -e "\n\n" >> #{@logDir})

        %x(echo -e "================= snmptt.debug =================" >> #{@logDir})
        %x(tail -300 /var/log/snmptt/snmptt.debug >> #{@logDir})        
        %x(echo -e "\n\n" >> #{@logDir})

        filePath = Rails.root.join('public', 'tech-support.log')
        send_file(filePath)
    end

end
