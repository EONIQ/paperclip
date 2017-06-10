module Paperclip
  class GeometryDetector
    def initialize(file)
      @file = file
      raise_if_blank_file
    end

    def make
      geometry = GeometryParser.new(geometry_string.strip).make
      geometry || raise(Errors::NotIdentifiedByImageMagickError.new)
    end

    private

    def geometry_string
      begin
        orientation = Paperclip.options[:use_exif_orientation] ?
          "%[exif:orientation]" : "1"
        Paperclip.run(
          "identify",
          "-format '%wx%h,#{orientation}' :file", {
            :file => "#{url}[0]"
          }, {
            :swallow_stderr => true
          }
        )
      rescue Cocaine::ExitStatusError
        ""
      rescue Cocaine::CommandNotFoundError => e
        raise_because_imagemagick_missing
      end
    end

    def url
      @file.respond_to?(:url) ? @file.url : @file
    end

    def path
      @file.respond_to?(:path) ? @file.path : @file
    end

    def raise_if_blank_file
      if path.blank?
        raise Errors::NotIdentifiedByImageMagickError.new("Cannot find the geometry of a file with a blank name")
      end
    end

    def raise_because_imagemagick_missing
      raise Errors::CommandNotFoundError.new("Could not run the `identify` command. Please install ImageMagick.")
    end
  end
end
