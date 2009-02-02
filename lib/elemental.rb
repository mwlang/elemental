begin
  require 'lib/element'
rescue LoadError
  require 'element'
end

class Elemental

  VERSION = '0.1.1'

  class << self;
    include Enumerable

    attr_reader :value_as_ordinal

    # Causes the Element#value method to return ordinal value, which
    # normally returns the ruby symbol
    #
    # Note:  If you choose for Element#value to return ordinal and you are
    #   storing value to database, then you should always APPEND new elements
    #   to the declared Elemental class.  Otherwise, you WILL CHANGE the
    #   ordinal values and thus invalidate any persistent stores.  If you're
    #   not persistently storing ordinal values, then order of membership is moot.
    def persist_ordinally
      @value_as_ordinal = true
    end

    # Adds an element in the order given to the enumerable's class
    # Order matters if you store ordinal to database or other persistent stores
    def member(symbol, options={})
      @unordered_elements ||= {}
      @ordered_elements ||= []
      symbol = conform_to_symbol(symbol)

      element = Element.new(self, symbol, @ordered_elements.size,
        :display => options[:display] || symbol.to_s,
        :position => options[:position],
        :default => options[:default]
        )

      @unordered_elements[symbol] = element
      @ordered_elements << element
    end

    # allows you to define aliases for a given member with adding
    # additional elements to the elemental class.
    #
    #    class Fruit < Elemental
    #      member :apple
    #      member :kiwi
    #      synonym :machintosh, :apple
    #    end
    #
    # will yield an Elemental with only two elements (apple and kiwi),
    # but give the ability to retrieve Fruit::apple using Fruit::machintosh
    def synonym(new_symbol, existing_symbol)
      element = self[existing_symbol]
      @unordered_elements[conform_to_symbol(new_symbol)] = element
    end

    # Returns the first element in this class
    def first
      @ordered_elements.first
    end

    # Returns the last element in this class
    def last
      @ordered_elements.last
    end

    # Returns the number of elements added
    def size
      @ordered_elements.size
    end

    # Returns the element that follows the given element.  If given element is
    # last element, then first element is returned.
    def succ(value)
      index = self[value].to_i + 1
      (index >= size) ? first : @ordered_elements[index]
    end

    # Returns the element that precedes the given element.  If given element is
    # the first element, then last element is returned.
    def pred(value)
      index = self[value].to_i - 1
      (index < 0) ? last : @ordered_elements[index]
    end

    # Shortcut to getting to a specific element
    # Can get by symbol or constant (i.e. Color[:red] or Color[:Red])
    def [](value)
      value.is_a?(Fixnum) ? get_ordered_element(value) : get_unordered_element(value)
    end

    # iterates over the elements, passing each to the given block
    def each(&block)
      @ordered_elements.each(&block)
    end

    # Allows Car::honda
    def method_missing(value)
      self[value]
    end

    # Allows Car::Honda
    def const_missing(const)
      get_unordered_element(const)
    end

    # Returns all elements that are flagged as a default
    def defaults
      @ordered_elements.select{|s| s.default?}
    end

    # Outputs a sensible inspect string
    def inspect
      "#<#{self}:#{object_id} #{@ordered_elements.inspect}>"
    end

    private

    # Takes a "CamelCased-String" and returns "camel_cased_string"
    def underscore(camel_cased_word)
      camel_cased_word.to_s.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
        downcase
    end

    # Transforms given string or symbol
    # into a :lowered_case_underscored_symbol
    def conform_to_symbol(text_or_symbol)
      underscore(text_or_symbol.to_s).downcase.to_sym
    end

    # returns the nth element, raising an exception if index out of bounds
    def get_ordered_element(index)
      result = @ordered_elements[index]
      raise RuntimeError if result.nil?
      result
    end

    # returns the requested element by name, raising exception if non-existent
    def get_unordered_element(what)
      result = @unordered_elements[conform_to_symbol(what)]
      raise RuntimeError if result.nil?
      result
    end
  end
end
