# This fact simply makes an http request to the localhost on port 4040 to see
# what's going on.  (Currently, just looking at the tunnels.)  Since that
# returns valid JSON, we can just blindly stuff that into the fact value.

require 'net/http'
require 'json'

Facter.add('ngrok') do

  # Don't bother trying unless we're on Linux
  confine :kernel => 'Linux'

  setcode do

    # If ngrok seems to be running, see what the API says are the active
    # tunnels.  If it's not running, this never happens, which makes the fact's
    # value nil.
    if ( `ps aux | grep 'ngrok start' | grep -v 'grep'` != "" )

      http = Net::HTTP.new('localhost',4040)
      request = Net::HTTP::Get.new('/api/tunnels')
      request['Content-Type'] = "application/json"
      tunnels = http.request(request)
      JSON.parse(tunnels.body)

    end

  end

end
