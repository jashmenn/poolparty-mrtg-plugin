require ::File.join(File.dirname(__FILE__), "monitorings")
module PoolParty
  class Plugins
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
      include PoolParty::Mrtg::Monitorings

      def enable
        install
      end

      def monitor(*names)
        unless @installed_mrtg_monitors
          names.each {|arg| (@@monitors ||= []) << arg}
          @installed_mrtg_monitors = true
        end
        install
      end
            
      def install
       unless @installed
          has_package(:name => "mrtg", :ensures => "installed", :requires => get_package("snmpd"))
          has_package(:name => "snmpd")

          has_directory("/var/www/mrtg", :requires => get_package("mrtg"))

          prepare_monitors
          install_monitor_base_binaries
          create_configs

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

      def prepare_monitors
        unless @prepared_mrtg_monitors
          @@monitors.each do |name|
            self.send("enable_#{name}")
          end
          @prepared_mrtg_monitors = true
        end
      end

      def create_configs
        unless @configs
          has_variable(:name => "community_name", :value => "poolpartycommunity")
          has_variable(:name => "mrtg_bin_dir",   :value => "/usr/bin/mrtg")
          has_variable(:name => "internal_ip", :value => "generate('/usr/bin/curl', '-s', 'http://169.254.169.254/latest/meta-data/local-ipv4')") # or hostname -i | cut -d " " -f3-

          has_file({:name => "/etc/default/snmpd", 
                    :template => File.dirname(__FILE__) + "/templates/snmpd",
                    :mode => 644})

          has_file({:name => "/etc/snmp/snmpd.conf", 
                    :template => File.dirname(__FILE__) + "/templates/snmpd.conf",
                    :mode => 644})

          # concat all monitor configs
          mrtg_cnf = File.read(File.dirname(__FILE__) + "/templates/mrtg.cfg.erb")
          @@monitors.each do |name| 
            cf = File.dirname(__FILE__) + "/templates/cfg/#{name}.cfg"
            (mrtg_cnf << "\n" << File.read(cf)) if File.exists?(cf)
          end

          File.open(PoolParty::Cloud::Base.storage_directory + "/templates/mrtg.cfg.erb", "w") do |f|
            f << mrtg_cnf
          end

          has_file({:name => "/etc/mrtg.cfg", 
                    :content => "template('mrtg.cfg.erb')",
                    :mode => 644})

          @configs = true
        end
      end

      def install_monitor_base_binaries
        has_directory("/usr/bin/mrtg")

        Dir.glob(File.dirname(__FILE__) + "/templates/bin/*.*").each do |filename| 
          helper_bin(File.basename(filename))
        end
      end

      def helper_bin(name, ensureer='present')
        has_file(:name => "/usr/bin/mrtg/#{name}") do
          template File.dirname(__FILE__) + "/templates/bin/#{name}"
          ensures ensureer          
          mode 755
        end
      end

    end
  end
end
