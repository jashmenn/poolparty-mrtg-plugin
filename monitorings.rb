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

      def enable_uptime
      end

      def enable_apache
        present_apache_module("status")
      end

    end
  end
end
 

