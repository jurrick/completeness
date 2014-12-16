module Completeness
  class Field
    DEFAULT_WEIGHT = 10

    attr_reader :spec, :name, :options

    def initialize(spec, name, options = {})
      @spec = spec
      @name = name
      @options = options
    end

    def required?
      !!options[:required]
    end

    def get_attribute_value(object)
      if name.is_a?(Array) && get_attribute_type(object) == :json
        h = object.send(name[0])
        name[1..-1].inject(h) { |v, n| v[n.to_s] }
      else
        object.send(name)
      end
    end

    def get_attribute_type(object)
      n = name.is_a?(Array) ? name[0] : name
      object.class.columns_hash[n.to_s].type
    end

    def completed?(object)
      completeness_check.call(object, get_attribute_value(object))
    end

    def weight
      options[:weight] || DEFAULT_WEIGHT
    end

    def <=>(other)
      return 1 if required? && !other.required?
      return -1 if !required? && other.required?
      weight <=> other.weight
    end

    def weight_in_percent
      (weight / (spec.total_weight / 100.0)).round
    end

    def completeness_check
      if options[:check].present? && options[:check].respond_to?(:call)
        options[:check]
      else
        ->(obj, value){ value.present? }
      end
    end
  end
end
