class WickedPdf

  @@config = {}
  cattr_accessor :config

  def initialize(wkhtmltopdf_binary_path = nil)
    binary = WickedPdf::Binary.new(wkhtmltopdf_binary_path)
    @exe_path = binary.exe_path
    @binary_version = binary.version
    @env = WickedPdf::Environment.new
  end

  def pdf_from_string(string, options={})
    temp_path = options.delete(:temp_path)
    string_file = WickedPdfTempfile.new("wicked_pdf.html", temp_path)
    string_file.binmode
    string_file.write(string)
    string_file.close
    generated_pdf_file = WickedPdfTempfile.new("wicked_pdf_generated_file.pdf", temp_path)
    command = "\"#{@exe_path}\" #{'-q ' unless @env.on_windows?}#{parse_options(options)} \"file:///#{string_file.path}\" \"#{generated_pdf_file.path}\" " # -q for no errors on stdout
    print_command(command) if @env.in_development_mode?
    err = Open3.popen3(command) do |stdin, stdout, stderr|
      stderr.read
    end
    if return_file = options.delete(:return_file)
      return generated_pdf_file
    end
    generated_pdf_file.rewind
    generated_pdf_file.binmode
    pdf = generated_pdf_file.read
    raise "PDF could not be generated!\n Command Error: #{err}" if pdf and pdf.rstrip.length == 0
    pdf
  rescue Exception => e
    raise "Failed to execute:\n#{command}\nError: #{e}"
  ensure
    string_file.close! if string_file
    generated_pdf_file.close! if generated_pdf_file && !return_file
  end

  private

  def print_command(cmd)
    p "*"*15 + cmd + "*"*15
  end

  def parse_options(options)
    WickedPdf::OptionsParser.new(options).to_command
  end

end