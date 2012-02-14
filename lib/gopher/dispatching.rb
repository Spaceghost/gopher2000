module Gopher
  module Dispatching

    attr_accessor :params, :request

    #
    # find and run routes which match the incoming request
    #
    def dispatch(req)
      response = Response.new
      @request = req

      if ! @request.valid?
        response.body = handle_invalid_request(@request)
        response.code = :error
        return response
      end

      begin
        @params, block = lookup(@request.selector)

        # call the block that handles this lookup
        response.body = block.bind(self).call
        response.code = :success

      rescue Gopher::NotFoundError => e
        response.body = handle_not_found(@request)
        response.code = :missing
      # rescue Exception => e
      #   response.body = handle_error(@request, e)
      #   response.code = :error
      end

      response
    end

    #
    # lookup an incoming path
    #
    def lookup(selector)
      unless routes.nil?
        routes.each do |pattern, keys, block|
          if match = pattern.match(selector)
            match = match.to_a
            url = match.shift

            params = to_params_hash(keys, match)

            @params = params
            return params, block
          end
        end
      end

      unless @default_route.nil?
        return {}, @default_route
      end

      raise Gopher::NotFoundError
    end


    #
    # zip up two arrays of keys and values from an incoming request
    #
    def to_params_hash(keys,values)
      hash = {}
      keys.size.times { |i| hash[ keys[i].to_sym ] = values[i] }
      hash
    end

    def not_found_template
      t = find_template('not_found')
      if t.nil?
        menu :'internal/not_found' do
          text "bummer"
        end
        find_template(:'internal/not_found')
      end
    end

    def handle_not_found(request)
      not_found_template.bind(self).call
    end

    # def handle_invalid_request(request)
    #   unless @error_request.nil?
    #     @error_request.bind(self).call
    #   else
    #     Proc.new {
    #       text "hi"
    #     }.call
    #   end
    # end



    class << self
      def generate_method(method_name, &block)
        define_method(method_name, &block)
        method = instance_method method_name
        remove_method method_name
        method
      end
    end
  end
end
