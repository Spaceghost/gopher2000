module Gopher

  #
  # Handle communication between Server and the actual gopher Application
  #
  class Dispatcher < EventMachine::Connection

    # the Application we are running
    attr_accessor :app

    #
    # get the IP address of the client
    # @return ip address
    #
    def remote_ip
      Socket.unpack_sockaddr_in(get_peername).last
    end


    #
    # called by EventMachine when there's an incoming request
    # roughly matching sinatra's style of duping the app to respond
    # to requests, @see http://www.sinatrarb.com/intro#Request/Instance%20Scope
    #
    # this essentially means we have 'one instance per request'
    #
    # @param [String] incoming selector
    # @return Response object
    #
    def receive_data(selector)
      dup.call!(selector)
    end

    #
    # generate a request object from an incoming selector, and dispatch it to the app
    # @param [String] incoming selector
    # @return Response object
    #
    def call!(selector)
      # parse out the request
      @request = Request.new(selector, remote_ip)

      operation = proc {
        resp = app.dispatch(@request)
        resp
      }
      callback = proc {|result|
        send_response result
        close_connection_after_writing
      }

      #
      # if we don't want to block on slow calls, use EM#defer
      # @see http://eventmachine.rubyforge.org/EventMachine.html#M000486
      #
      if app.non_blocking?
        EventMachine.defer( operation, callback )
      else
        callback.call(operation.call)
      end
    end

    #
    # send the response back to the client
    # @param [Response] response object
    #
    def send_response(response)
      case response
      when Gopher::Response then send_response(response.body)
      when String then send_data(response + end_of_transmission)
      when StringIO then send_data(response.read + end_of_transmission)
      when File
        while chunk = response.read(8192) do
          send_data(chunk)
        end
        response.close
      end
    end

    #
    # Add the period on a line by itself that closes the connection
    #
    # @return valid string to mark end of transmission as specified in RFC1436
    def end_of_transmission
      [Gopher::Rendering::LINE_ENDING, ".", Gopher::Rendering::LINE_ENDING].join
    end

  end
end
