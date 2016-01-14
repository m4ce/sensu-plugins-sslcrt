#!/usr/bin/env ruby
#
# check-sslcrt.rb
#
# Author: Matteo Cerutti <matteo.cerutti@hotmail.co.uk>
#

require 'sensu-plugin/check/cli'
require 'time'

class CheckSslCrt < Sensu::Plugin::Check::CLI
  option :connect,
         :description => "This specifies the host and optional port to connect to",
         :long => "--connect <HOST>[:<PORT>]",
         :default => nil

  option :file,
         :description => "This specifies the input filename to read a certificate from",
         :short => "-f <CERT_FILE>",
         :long => "--file <CERT_FILE>",
         :default => nil

  option :warn,
         :description => "Warn if expiration date is DAYS away",
         :short => "-w <DAYS>",
         :long => "--warn <DAYS>",
         :proc => proc(&:to_i),
         :default => 25

  option :crit,
         :description => "Critical if expiration date is DAYS away",
         :short => "-c <DAYS>",
         :long => "--crit <DAYS>",
         :proc => proc(&:to_i),
         :default => 10

  def initialize()
    super

    raise "Must provide either --connect or --file command line options" if (config[:connect] and config[:file]) or (!config[:connect] and !config[:file])
    raise "Critical threshold must be lower than the warning threshold" if config[:crit] >= config[:warn]
  end

  def expiration_date()
    if config[:connect]
      date = %x[openssl s_client -connect #{config[:connect]} 2>/dev/null </dev/null | openssl x509 -noout -dates]
    else
      date = %x[openssl x509 -enddate -noout -in #{config[:file]}]
    end

    Time.parse(date[/^notAfter=(.*)/, 1])
  end

  def run
    days_left = ((expiration_date() - Time.now) / 86400).to_i

    if config[:connect]
      msg = "SSL certificate for host #{config[:connect]} will expire in #{days_left} days"
    else
      msg = "SSL certificate file '#{config[:file]}' will expire in #{days_left} days"
    end

    critical(msg + " (<= #{config[:crit]})") if days_left <= config[:crit]
    warning(msg + " (<= #{config[:warn]})") if days_left <= config[:warn]
    ok(msg + " (> #{config[:warn]})")
  end
end
