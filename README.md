PoolParty MRTG plugin
=====================

DESCRIPTION:
===========

Setup mrtg on poolparty easy as pie
  
USAGE:
======

Declare mrtg in your cloud block

    mrtg do
       monitor :cpu, :uptime, :memory, :open_files, :processes, :apache, :network_interfaces
    end

Available Monitors
==================

see:

    poolparty-mrtg-plugin/templates/cfg/ 

for the list.

NOTICE:
=======

This should be considered beta software. It enables smtp on your nodes.
Please make sure you understand the security ramifications of doing this.

Additionally, the scripts have only been tested in a production environment
for a short time.

BUGS:
=====

  * "ExtendedStatus On" needs to be manually added to an apache conf file to
    get apache monitoring

  * SNMP should be an optional install. Most scripts already do not need them.

AUTHORS:
========
Plugin written by Nate Murray 2008
Most MRTG scripts taken from: http://www.linux-sottises.net/en_mrtg.php


