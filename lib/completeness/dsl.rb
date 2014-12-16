module Completeness
  class DSL
    def initialize(options = {}, &block)
      @default_options = options
      instance_eval(&block)
    end

    def field(name, options = {})
      spec[attribute_fullname(name)] = Field.new(spec, name, default_options.merge(options))
    end

    def spec
      @spec ||= Specification.new
    end

    private
    attr_reader :default_options

    def attribute_fullname(name)
      if name.is_a?(Array)
        name[0].to_s + name[1..-1].inject('') { |str, el| "#{str}[#{el}]" }
      else
        name
      end
    end
  end
end
