class WickedPdf
  class Option

    attr_accessor :name, :value, :type

    def initialize(name, value, type=:string)
      self.name = name
      self.value = value
      self.type = type
    end

    def to_s
      if value.is_a?(Array)
        return value.collect { |v| self.class.new(name, v, type) }.join('')
      end
      "--#{name.gsub('_', '-')} " + case type
        when :boolean then ""
        when :numeric then value.to_s
        when :name_value then value.to_s
        else "\"#{value}\""
      end + " "
    end

  end
end