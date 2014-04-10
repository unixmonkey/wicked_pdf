class WickedPdf
  class Environment

    def on_windows?
      RbConfig::CONFIG['target_os'] =~ /mswin|mingw/
    end

    def in_development_mode?
      return Rails.env == 'development' if defined?(Rails)
      RAILS_ENV == 'development' if defined?(RAILS_ENV)
    end

  end
end