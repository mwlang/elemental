=begin
Copyright (c) 2009 Michael Lang

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
=end

begin
  require 'lib/element'
rescue LoadError
  require 'element'
end

module Elemental

  VERSION = '0.1.2'

  include Enumerable

  ##
  # Affects whether #value returns symbolic name for element or ordinal value
  # @return [true or false] value is ordinal value when true
  attr_reader :value_as_ordinal

  ##
  # Causes the Element#value method to return ordinal value, which
  # normally returns the ruby symbol
  #
  # @note  If you choose for Element#value to return ordinal and you are
  # storing value to database, then you should always APPEND new elements
  # to the declared Elemental class.  Otherwise, you WILL CHANGE the
  # ordinal values and thus invalidate any persistent stores.  If you're
  # not persistently storing ordinal values, then order of membership is moot.
  def persist_ordinally
    @value_as_ordinal = true
  end

  ##
  # Adds an element in the order given to the enumerable's class
  # Order matters if you store ordinal to database or other persistent stores
  def member(symbol, options={})
    @unordered_elements ||= {}
    @ordered_elements ||= []
    symbol = conform_to_symbol(symbol)
    element = Element.new(self, symbol, @ordered_elements.size, options)

    @unordered_elements[symbol] = element
    @ordered_elements << element
  end

  ##
  # Allows you to define aliases for a given member with adding
  # additional elements to the elemental class.
  #
  #    class Fruit
  #      extend Elemental
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

  ##
  # Returns the first element in this class
  #
  # @return [Element]
  def first
    @ordered_elements.first
  end

  ##
  # Returns the last element in this class
  #
  # @return [Element]
  def last
    @ordered_elements.last
  end

  ##
  # Returns the number of elements added
  #
  # @return [Fixnum]
  def size
    @ordered_elements.size
  end

  ##
  # Returns the element that follows the given element.  If given element is
  # last element, then first element is returned.
  #
  # @param [Symbol] value the symbolic reference to the element
  # @return [Element]
  def succ(value)
    index = self[value].to_i + 1
    (index >= size) ? first : @ordered_elements[index]
  end

  ##
  # Returns the element that precedes the given element.  If given element is
  # the first element, then last element is returned.
  #
  # @param [Symbol] value the symbolic reference to the element
  # @return [Element]
  def pred(value)
    index = self[value].to_i - 1
    (index < 0) ? last : @ordered_elements[index]
  end

  ##
  # Shortcut to getting to a specific element
  # Can get by symbol or constant (i.e. Color[:red] or Color[:Red])
  #
  # @param [Symbol, Fixnum] value the Element to retrieve, referenced either by ordinal 
  # position or by symbolic representation for the element.
  #
  # @return [Element]
  def [](value)
    value.is_a?(Fixnum) ? get_ordered_element(value) : get_unordered_element(value)
  end

  ##
  # Iterates over the elements, passing each Element to the given block
  def each(&block)
    @ordered_elements.each(&block)
  end

  ##
  # Allows Car::honda
  # @return [Element]
  def method_missing(value)
    self[value]
  end

  ##
  # Allows Car::Honda
  # @return [Element]
  def const_missing(const)
    get_unordered_element(const)
  end

  ##
  # Returns all elements that are flagged as a default
  # @return [Array of Element]
  def defaults
    @ordered_elements.select{|s| s.default?}
  end

  ##
  # Outputs a sensible inspect string
  # @return [String]
  def inspect
    "#<#{self}:#{object_id} #{@ordered_elements.inspect}>"
  end

  private

  ##
  # Takes a "CamelCased-String" and returns "camel_cased_string"
  # @return [String]
  # @author Rails team
  def underscore(camel_cased_word)
    camel_cased_word.to_s.
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase
  end

  ##
  # Transforms given string or symbol
  # into a :lowered_case_underscored_symbol
  # @return [Symbol]
  def conform_to_symbol(text_or_symbol)
    underscore(text_or_symbol.to_s).downcase.to_sym
  end

  ##
  # returns the nth element, raising an exception if index out of bounds
  # @return [Element]
  def get_ordered_element(index)
    result = @ordered_elements[index]
    raise RuntimeError if result.nil?
    result
  end

  ##
  # returns the requested element by name, raising exception if non-existent
  # @return [Element]
  def get_unordered_element(what)
    result = @unordered_elements[conform_to_symbol(what)]
    raise RuntimeError if result.nil?
    result
  end
end
