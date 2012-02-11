module Gopher
  module Handlers
    #
    # base class for custom request handlers.  doesn't do much other
    # than include rendering methods right now.
    #
    # @todo request sanitation here?
    #
    class BaseHandler
      include Rendering
    end
  end
end
