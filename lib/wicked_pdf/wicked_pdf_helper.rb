require 'open-uri'

module WickedPdfHelper
  def self.root_path
    String === Rails.root ? Pathname.new(Rails.root) : Rails.root
  end

  def self.add_extension(filename, extension)
    (File.extname(filename.to_s)[1..-1] == extension) ? filename : "#{filename}.#{extension}"
  end

  def wicked_pdf_stylesheet_link_tag(*sources)
    css_dir = WickedPdfHelper.root_path.join('public', 'stylesheets')
    css_text = sources.collect { |source|
      source = WickedPdfHelper.add_extension(source, 'css')
      "<style type='text/css'>#{File.read(css_dir.join(source))}</style>"
    }.join("\n")
    css_text.respond_to?(:html_safe) ? css_text.html_safe : css_text
  end

  def wicked_pdf_image_tag(img, options={})
    image_tag "file:///#{WickedPdfHelper.root_path.join('public', 'images', img)}", options
  end

  def wicked_pdf_javascript_src_tag(jsfile, options={})
    jsfile = WickedPdfHelper.add_extension(jsfile, 'js')
    src = "file:///#{WickedPdfHelper.root_path.join('public', 'javascripts', jsfile)}"
    content_tag("script", "", { "type" => Mime::JS, "src" => path_to_javascript(src) }.merge(options))
  end

  def wicked_pdf_javascript_include_tag(*sources)
    js_text = sources.collect{ |source| wicked_pdf_javascript_src_tag(source, {}) }.join("\n")
    js_text.respond_to?(:html_safe) ? js_text.html_safe : js_text
  end

  module Assets

    # borrowed from actionpack/lib/action_view/helpers/asset_url_helper.rb
    URI_REGEXP = %r{^[-a-z]+://|^(?:cid|data):|^//}

    def wicked_asset(path)
      return wicked_uri(path) if path =~ URI_REGEXP
      asset = wicked_asset_from_assets(path) ||
              wicked_asset_from_public(path)
      if asset
        wicked_base64(asset)
      else
        wicked_asset_error(path)
      end
    end

    private

    # wkhtmltopdf doesn't work well with protocol neutral URIs
    def wicked_uri(uri)
      if uri[0,2] == '//'
        protocol = WickedPdf.config[:default_protocol] || 'http'
        [protocol, ':', uri].join
      else
        uri
      end
    end

    def wicked_asset_from_assets(path)
      Rails.application.assets.find_asset(path)
    end

    def wicked_asset_from_public(path)
      environment = Rails.application.assets
      path_parts = path.split('/').reject(&:blank?)
      pathname = Rails.public_path.join(*path_parts)
      if pathname.file?
        Sprockets::StaticAsset.new(environment, pathname, pathname)
      end
    end

    def wicked_base64(asset)
      base64 = Base64.encode64(asset.to_s).gsub(/\s+/, '')
      "data:#{asset.content_type};base64,#{Rack::Utils.escape(base64)}"
    end

    def wicked_asset_error(path)
      if WickedPdf.config[:raise_asset_errors]
        raise ArgumentError, "Could not find asset '#{path}'"
      end
    end

  end
end
