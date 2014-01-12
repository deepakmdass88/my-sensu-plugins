require 'rubygems'
require 'sensu-handler'
require 'timeout'
require 'securerandom'
require 'plivo'
require 'redis'
require 'timeout'


class PLIVO < Sensu::Handler

  def short_name
    @event['client']['name'] + '/' + @event['check']['name']
  end

  def action_to_string
    @event['action'].eql?('resolve') ? "RESOLVED" : "ALERT"
  end

  def handle
    plivo_auth_id = "XXXXXXXXXXXXXXXX"          # => available at the plivo dashboard
    plivo_auth_token = "XXXXXXXXXXXXXXXX"       # => available at the plivo dashboard
    body = <<-BODY.gsub(/^ {14}/, '')
            #{@event['check']['output']}
            Host: #{@event['client']['name']}
           BODY
    uuid = SecureRandom.hex
    r = Redis.new(:host => "<redis_host_name>", :port => <redis_port>, :password => "<redis_pass>")
    temp = {
            'text' => "#{body}"
            }
    plivo_number = "<YOUR PLIVO NUMBER"
    to_number = "<DESTINATION NUMBER>"
    answer_url = "<YOUR HEROKU APP URL>/#{uuid}"
    call_params = {
                     'from' => plivo_number,
                     'to' => to_number,
                     'answer_url' => answer_url,
                     'answer_method' => 'GET'
                     }
         r.set "#{uuid}", temp.to_json
         r.expire "#{uuid}", <EXPIRY TTL>
         sleep 5
     begin
       timeout 10 do
         puts "Connecting to Plivo Cloud.."
         plivo = Plivo::RestAPI.new(plivo_auth_id, plivo_auth_token)
     details = plivo.make_call(call_params)
       end
       rescue Timeout::Error
       puts "timed out while attempting to contact Plivo Cloud"
         end
  end
end
