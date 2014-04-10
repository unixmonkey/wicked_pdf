class WickedPdf
  class Binary

    DEFAULT_BINARY_VERSION = Gem::Version.new('0.9.9')

    attr_accessor :exe_name, :exe_path, :version

    def initialize(wkhtmltopdf_binary_path = nil)
      self.exe_name = WickedPdf.config[:exe_name] || 'wkhtmltopdf'
      self.exe_path = wkhtmltopdf_binary_path || find_wkhtmltopdf_binary_path
      validate_executable(exe_name, exe_path)
      self.version = get_version
    end

    private

    def validate_executable(name, path)
      raise "Location of #{name} unknown" if path.empty?
      raise "Bad #{name}'s path" unless File.exists?(path)
      raise "#{name} is not executable" unless File.executable?(path)
    end

    def get_version
      if WickedPdf.config[:retrieve_version]
        retreive_binary_version
      else
        DEFAULT_BINARY_VERSION
      end
    end

    def retreive_binary_version
      stdin, stdout, stderr = Open3.popen3(exe_path + ' -V')
      parse_version(stdout.gets(nil))
    rescue StandardError
    end

    def parse_version(version_info)
      match_data = /wkhtmltopdf\s*(\d*\.\d*\.\d*\w*)/.match(version_info)
      if (match_data && (2 == match_data.length))
        Gem::Version.new(match_data[1])
      else
        DEFAULT_BINARY_VERSION
      end
    end

    def find_wkhtmltopdf_binary_path
      possible_locations = (ENV['PATH'].split(':')+%w[/usr/bin /usr/local/bin ~/bin]).uniq
      exe_path ||= WickedPdf.config[:exe_path] unless WickedPdf.config.empty?
      exe_path ||= begin
        (defined?(Bundler) ? `bundle exec which wkhtmltopdf` : `which wkhtmltopdf`).chomp
      rescue Exception => e
        nil
      end
      exe_path ||= possible_locations.map{|l| File.expand_path("#{l}/#{exe_name}") }.find{|location| File.exists? location}
      exe_path || ''
    end

  end
end