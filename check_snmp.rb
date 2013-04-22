# Check SNMP
# ===
#
# This is a simple SNMP check script for Sensu, We need to supply details like
# Server, port, SNMP community, and Limits
# Examples:
#
#   check-snmp -h host -C community -O oid -w warning -c critical
#
#
#  Author DeepakMDas   <deepakmdass88@gmail.com>
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.


require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/check/cli'
require 'snmp'


class CheckProcs < Sensu::Plugin::Check::CLI

  def self.read_pid(path)
    begin
      File.read(path).chomp.to_i
    rescue
      self.new.unknown "Could not read pid file #{path}"
    end
  end

option :host, :short => '-h host', :boolean => true, :default => "127.0.0.1"
option :community, :short => '-C snmp community', :boolean =>true, :default => "public"
option :objectid, :short => '-O OID', :default => "1.3.6.1.4.1.2021.10.1.3.1"
option :warning, :short => '-w warning', :default => "1"
option :critical, :short => '-c critical', :default => "2"

def run
manager = SNMP::Manager.new(:host => "#{config[:host]}", :community => "#{config[:community]}" )
response = manager.get(["#{config[:objectid]}"])
 response.each_varbind do |vb|

	 if "#{vb.value.to_s}" > "#{config[:critical]}"
    		msg = "Critical state detected"
  	  	critical msg
    	 else
      	   if "#{vb.value.to_s}" > "#{config[:warning]}"
      	  	 msg = "Warning state detected"
     	         warning msg
            else
        	 msg = "All is well Dude"
        	 ok msg
   	    end
	  end
     end
  manager.close
  end
end
