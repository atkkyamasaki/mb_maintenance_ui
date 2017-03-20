class SnmpsController < ApplicationController

    def show 
        snmpttFiles = %x(ls /etc/snmp/snmptt.conf.d/*.conf | sed -e 's|/etc/snmp/snmptt.conf.d/||g')
        @snmptt = []
        snmpttFiles.each_line { |val|
            @snmptt.push(val.chomp)
        }
 
        mibFiles = %x(ls /usr/share/netmon/mibs/*.mib | sed -e 's|/usr/share/netmon/mibs/||g')
        @mib = []
        mibFiles.each_line { |val|
            @mib.push(val.chomp)
        }




    end

end
