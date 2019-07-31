require 'byebug'
module MyEnum
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def enum(definitions)
      definitions.each do |attribute_name, value_names|
        define_enum_methods(attribute_name, pretty(value_names))
      end
    end

    def pretty(value_names)
      if value_names.is_a?(Hash)
        value_names
      elsif value_names.is_a?(Array)
        value_names.map.with_index.with_object({}) do |item, memo|
          memo[item[0]] = item[1]
        end
      end
    end

    def define_enum_methods(attribute_name, value_names)

      define_method(attribute_name) do
        value_names.invert[instance_variable_get("@#{attribute_name}")]
      end

      value_names.each do |value_name, value|
        # instance methods
        define_method("#{value_name}?") {
          send(attribute_name).to_s == value_name.to_s
        }
        define_method("#{value_name}!") {
          instance_variable_set("@#{attribute_name}", value)
        }

        # class methods
        define_singleton_method("#{value_name}") {
          $database.select { |record| record.public_send("#{value_name}?") }
        }

        define_singleton_method("not_#{value_name}") {
          $database.reject { |record| record.public_send("#{value_name}?") }
        }
      end
    end
  end
end
