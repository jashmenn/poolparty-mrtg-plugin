module PoolParty
  module Mrtg
    module Monitorings

      def enable_cpu
          has_package("sysstat")

          has_cron(:name => "Run sysstat sa1", 
                   :command => "/usr/lib/sysstat/sa1 -d 1 1",
                   :minute => "*/10")

          has_cron(:name => "Run sysstat sa2", 
                   :command => "/usr/lib/sysstat/sa2 -A",
                   :hour   => "23",
                   :minute => "53")
      end

      def enable_apache
        present_apache_module("status")
        has_package("lynx") # todo, remove this dependency
      end

      # The enable statements below are not required to add something to the
      # mrtg config. However, they can be used if you want to enable specific
      # dependencies for a particular monitoring.

      def enable_uptime
      end

      def enable_disk 
      end

      def enable_memory
      end
      
      def enable_processes
      end
      
      def enable_uptime
      end

      def enable_free_memory
      end

      def enable_open_files
      end 

      def enable_snmp_network
      end

    end
  end
end
 

