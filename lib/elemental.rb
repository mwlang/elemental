require 'lib/element'
 
class Elemental

  VERSION = '0.1.0'

  class << self; 
    include Enumerable
    
    # Adds an element in the order given to the enumerable's class
    def member(symbol, options={})
      @unordered_elements ||= {}
      @ordered_elements ||= []
      symbol = conform_symbol(symbol)
      element = Element.new(self, symbol, @ordered_elements.size, 
        :display => options[:display] || symbol.to_s, 
        :position => options[:position],
        :default => options[:default]
        )

      @unordered_elements[symbol] = element
      @ordered_elements << element
    end

    # Takes a "CamelCasedString" and returns "camel_cased_string"
    def underscore(camel_cased_word)
      camel_cased_word.to_s.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
        downcase
    end

    # Transforms whatever given string or symbol 
    # into a :lowered_case_underscored_symbol
    def conform_symbol(text)
      text = text.to_s if text.is_a?(Symbol)
      underscore(text).downcase.to_sym
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
    def succ(symbol)
      index = @unordered_elements[conform_symbol(symbol)].to_i + 1
      index = 0 if (index >= @ordered_elements.size)
      to_a[index]
    end

    # Returns the element that precedes the given element.  If given element is 
    # the first element, then last element is returned.
    def pred(symbol)
      index = @unordered_elements[conform_symbol(symbol)].to_i - 1
      index = @ordered_elements.size - 1 if (index < 0)
      @ordered_elements[index]
    end

    # Shortcut to getting to a specific element
    # Can get by symbol or constant (i.e. Color[:red] or Color[:Red])
    def [](symbol)
      @unordered_elements[conform_symbol(symbol)]
    end

    # iterates over the elements, passing each to the given block
    def each(&block) 
      @ordered_elements.each(&block) 
    end
        
    # Allows Car::honda
    def method_missing(symbol)
      @unordered_elements[conform_symbol(symbol)]
    end   

    # Allows Car::Honda
    def const_missing(const)
      @unordered_elements[conform_symbol(const)]
    end   
    
    # Returns all elements that are flagged as a default
    def defaults
      @ordered_elements.select{|s| s.default?}
    end

    # Outputs a sensible inspect string
    def inspect
      "#<#{self}:#{object_id} #{@ordered_elements.inspect}>"
    end
  end
end
