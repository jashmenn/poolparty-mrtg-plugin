require ::File.join(File.dirname(__FILE__), "virtual_resources")
require ::File.join(File.dirname(__FILE__), "monitorings")
module PoolParty
  class Plugins
    include PoolParty::Mrtg::Monitorings
    # MRTG plugin for poolparty
    #
    #
    # Note: This plugin does *not*
    #   * control the apache config to view the /var/www/mrtg file
    #   * add access control for the apache web interface
    #
    # You must add these things yourself
    # 
    # Helpful Hints:
    #  To test if snmp is working: 
    #    snmpwalk -Os -c poolpartycommunity -v 1 localhost system
    #    snmpwalk -v 1 -c poolpartycommunity localhost IP-MIB::ipAdEntIfIndex
    # 
    plugin :mrtg do
      def enable
        install
      end
            
      def install
       unless @installed
          has_package(:name => "mrtg", :ensures => "installed", :requires => get_package("snmpd"))
          has_package(:name => "snmpd")

          has_directory("/var/www/mrtg", :requires => get_package("mrtg"))

          configs

          has_exec(:name => "generate_mrtg_index_file", 
            :command => "/usr/bin/indexmaker --output=/var/www/mrtg/index.html /etc/mrtg.cfg", 
            :ifnot => "test -f /etc/apache2/conf.d/passenger.conf",
            :requires => [get_directory("/var/www/mrtg"), get_file("/etc/mrtg.cfg")]
            )

          has_cron(:name => "Run MRTG", 
                   :command => "/usr/bin/env LANG=C /usr/bin/mrtg /etc/mrtg.cfg --logging /var/log/mrtg.log", 
                   :minute => "*/5")

          @installed = true
        end    

      end

      def base_install        
        unless @base_install
          has_exec({:name => "restart-snmpd", :command => "/etc/init.d/snmpd restart", :refreshonly => "true"})

          configs
          @base_install = true
        end
      end

      def configs
        unless @configs

          has_file({:name => "/etc/mrtg.cfg", 
                    :template => File.dirname(__FILE__) + "/templates/mrtg.cfg.erb",
                    :mode => 644})

          has_file({:name => "/etc/default/snmpd", 
                    :template => File.dirname(__FILE__) + "/templates/snmpd",
                    :mode => 644})

           has_file({:name => "/etc/snmp/snmpd.conf", 
                    :template => File.dirname(__FILE__) + "/templates/snmpd.conf",
                    :mode => 644})

          @configs = true
        end
      end

      def monitor(*names)
      end

      def install_extra_monitorings
        unless @installed_extra_monitorings
          # install sysstat
          has_package("sysstat")

          has_cron(:name => "Run sysstat sa1", 
                   :command => "/usr/lib/sysstat/sa1 -d 1 1",
                   :minute => "*/10")

          has_cron(:name => "Run sysstat sa2", 
                   :command => "/usr/lib/sysstat/sa2 -A",
                   :hour   => "23",
                   :minute => "53")

          present_apache_module("status")

          @installed_extra_monitorings = true
        end
      end

    end
  end
end
