class Element

  attr_accessor :symbol, :ordinal, :display, :position, :default

  # Initializes a new element
  def initialize(elemental, symbol, ordinal, options={})
    @elemental = elemental
    @symbol = symbol
    @ordinal = ordinal
    @default = options[:default] || false
    @display = options[:display] || symbol.to_s
    @position = options[:position] || ordinal
  end

  def is?(value)
    self == (value.is_a?(Element) ? value : @elemental[value])
  end

  def value
    @elemental.value_as_ordinal ? to_i : to_sym
  end

  # Will sort on position (which defaults to ordinal if not explicitly set)
  def <=>(other)
    position <=> other.position
  end

  # Returns the element that follows this element.
  # If this is last element, returns first element
  def succ
    @elemental.succ(@symbol)
  end

  # Returns the element that precedes this element.
  # If this is the first element, returns last element
  def pred
    @elemental.pred(@symbol)
  end

  # Returns the symbol for this element as a string
  def to_s
    @symbol.to_s
  end

  # Returns this element's symbol
  def to_sym
    @symbol
  end

  # Returns the ordinal value for this element
  def index
    @ordinal
  end

  # Returns true if is default.  (useful if populating select lists)
  def default?
    @default
  end

  # Generates a reasonable inspect string
  def inspect
    "#<#{self.class}:#{self.object_id} {symbol => :#{@symbol}, " +
    "ordinal => #{@ordinal}, display => \"#{@display}\", " +
    "position => #{@position}, default => #{@default}}>"
  end

  # swiped from Rails...
  def humanize
    return @display if @display != to_s
    return self.to_s.gsub(/_id$/, "").gsub(/_/, " ").capitalize
  end

  alias :to_i :index
  alias :to_int :index
  alias :ord :index
end
