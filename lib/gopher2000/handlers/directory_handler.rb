require 'pathname'

module Gopher
  module Handlers
    #
    # handle browsing a directory structure/returning files to the client
    #
    class DirectoryHandler < BaseHandler

      attr_accessor :path, :filter, :mount_point

      #
      # opts:
      # filter -- a subset of files to show to user
      # path -- the base path of the filesystem to work from
      #
      def initialize(opts = {})
        opts = {
          :filter => "*.*",
          :path => Dir.getwd
        }.merge(opts)

        STDERR.puts "FILTER: #{opts[:filter]}"

        @path = opts[:path]
        @filter = opts[:filter]
        @mount_point = opts[:mount_point]
      end

      def sanitize(p)
        Pathname.new(p).cleanpath.to_s
      end

      #
      # make sure that the requested file is actually contained within our mount point. this
      # prevents requests like the below from working:
      #
      # echo "/files/../../../../../tmp/foo" | nc localhost 7070
      #
      def contained?(p)
        (p =~ /^#{@path}/) != nil
      end

      #
      # take the incoming parameters, and turn them into a path
      #
      def request_path(params)
        File.absolute_path(sanitize(params[:splat]), @path)
        #File.join(@path, sanitize(params[:splat]))
      end

      #
      # take the path to a file and turn it into a selector which will match up when
      # a gopher client makes requests
      #
      def to_selector(path)
        path.gsub(/^#{@path}/, @mount_point)
      end

      #
      # handle a request
      #
      # params - the params as parsed during the dispatching process - the main thing
      # here should be :splat, which will basically be the path requested.
      #
      # request - the Request object for this session -- not currently used?
      #
      def call(params = {}, request = nil)
        debug_log "DirectoryHandler: call #{params.inspect}, #{request.inspect}"

        lookup = request_path(params)

        raise Gopher::InvalidRequest if ! contained?(lookup)

        if File.directory?(lookup)
          directory(lookup)
        elsif File.file?(lookup)
          file(lookup)
        else
          raise Gopher::NotFoundError
        end
      end

      #
      # generate a directory listing
      #
      def directory(dir)
        m = Menu.new(@application)

        m.text "Browsing: #{dir}"

        #
        # iterate through the contents of this directory.
        # NOTE: we don't filter this, so we will ALWAYS list subdirectories of a mounted folder
        #
        Dir.glob("#{dir}/*.*").each do |x|
          # if this is a directory, then generate a directory link for it
          if File.directory?(x)
            m.directory File.basename(x), to_selector(x)

          elsif File.file?(x) && File.fnmatch(filter, x)
            # fnmatch makes sure that the file matches the glob filter specified in the mount directive

            # otherwise, it's a normal file link
            m.link File.basename(x), to_selector(x)
          end
        end
        m.to_s
      end

      #
      # return a file handle -- Connection will take this and send it back to the client
      #
      def file(f)
        File.new(f)
      end

    end
  end
end
