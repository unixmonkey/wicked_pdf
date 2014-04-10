# wkhtml2pdf Ruby interface
# http://code.google.com/p/wkhtmltopdf/

require 'logger'
require 'digest/md5'
require 'rbconfig'

if (RbConfig::CONFIG['target_os'] =~ /mswin|mingw/) && (RUBY_VERSION < '1.9')
  require 'win32/open3'
else
  require 'open3'
end

begin
  require 'active_support/core_ext/module/attribute_accessors'
rescue LoadError
  require 'active_support/core_ext/class/attribute_accessors'
end

begin
  require 'active_support/core_ext/object/blank'
rescue LoadError
  require 'active_support/core_ext/blank'
end

require 'wicked_pdf/version'
require 'wicked_pdf/binary'
require 'wicked_pdf/railtie'
require 'wicked_pdf/tempfile'
require 'wicked_pdf/middleware'
require 'wicked_pdf/wicked_pdf'
