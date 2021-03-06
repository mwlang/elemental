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
class Element

  attr_accessor :symbol, :ordinal, :display, :position, :default

  ##
  # Initializes a new element into the given Elemental Class
  #
  # @param [Elemental] elemental the "owning container" class
  # @param [Symbol] symbol the symbolic name for the element
  # @param [Fixnum] ordinal the desired ordinal value - defaults to position in list
  # @param [Hash] options A hash of additional options to associate with the element
  # @return [Element] Returns an instance for the given element properties
  #
  def initialize(elemental, symbol, ordinal, options={})
    @elemental = elemental
    @symbol = symbol
    @ordinal = ordinal
    
    # Sets all options and optionally creates an accessor method
    options.each do |k, v|
      eval("def #{k}; @#{k}; end") unless respond_to?(k)
      v.is_a?(String) ? eval("@#{k} = '#{v}'") : eval("@#{k} = #{v}")
    end
    
    # Force the following values (overrides above looped assignments)
    @default = options[:default] || false
    @display = options[:display] || symbol.to_s
    @position = options[:position] || ordinal
  end

  ## 
  # @return [true, false] Returns true if given value matches this Element's value
  #
  # @param [Symbol or Element] value the value we're are comparing against this element
  #
  def is?(value)
    self == (value.is_a?(Element) ? value : @elemental[value])
  end

  ## 
  # @return [Fixnum, Symbol] returns either the ordinal value or the symbol for 
  # this element.  The value type returned is determined by the value_as_ordinal property
  #
  def value
    @elemental.value_as_ordinal ? to_i : to_sym
  end

  ##
  # Will sort on position (which defaults to ordinal if not explicitly set)
  #
  # @param [Element] other the other Element to compare against
  #
  # @return [-1, 0, +1] 
  def <=>(other)
    position <=> other.position
  end

  ##
  # Returns the element that follows this element.
  # If this is last element, returns first element
  # @return [Element] 
  def succ
    @elemental.succ(@symbol)
  end

  ##
  # Returns the element that precedes this element.
  # If this is the first element, returns last element
  # @return [Element] 
  def pred
    @elemental.pred(@symbol)
  end
  
  ##
  # Returns the symbol for this element as a string
  # @return [String]
  def to_s
    @symbol.to_s
  end

  ## 
  # Returns this element's symbol
  # @return [Symbol]
  def to_sym
    @symbol
  end

  ##
  # Returns the ordinal value for this element
  # @return [Fixnum]
  def index
    @ordinal
  end

  ##
  # Returns true if is default.  (useful if populating select lists)
  # @return [true, false]
  def default?
    @default
  end

  ##
  # Generates a reasonable inspect string
  # @return [String]
  def inspect
    "#<#{self.class}:#{self.object_id} {symbol => :#{@symbol}, " +
    "ordinal => #{@ordinal}, display => \"#{@display}\", " +
    "position => #{@position}, default => #{@default}}>"
  end

  ## 
  # Will humanize the Element's symbolic name by removing underscores and trailing "_id"
  # monikers.  The words are capitialized.
  # @author swiped from Rails...
  # @return [String]
  def humanize
    return @display if @display != to_s
    return self.to_s.gsub(/_id$/, "").gsub(/_/, " ").capitalize
  end

  alias :to_i :index
  alias :to_int :index
  alias :ord :index
end
