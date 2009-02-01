= elemental

* git@github.com:mwlang/elemental.git
* Michael Lang, mwlang (at) cybrains (dot) net

== DESCRIPTION:

Elemental provides enumerated collection of elements that allow you to associate ruby symbols to arbitrary values, thus allowing your code to "think" symbolically and unambiguously while giving you the means to easily display what end-users need to see.  Additionally, symbols are associated with ordinal values, allowing easy storage/retrieval to persistent stores (e.g. databases).
Establish Elementals like this:

== FEATURES/PROBLEMS:

    * Code with symbols, easily display what the user needs to see.
    * Access elements in a variety of ways
    * Store in database as either string or ordinal value

== SYNOPSIS:

class ChartType < Elemental
  member :columns,         :display => 'Columns', :default => true
  member :stacked_columns, :display => "Stacked Columns"
  member :bars,            :display => "Bars"
  member :stacked_bars,    :display => "Stacked Bars"
  member :lines,           :display => "Lines"
  member :areas,           :display => "Shaded Areas"
end

class WidgetType < Elemental
  member :data_grid,   :display => "Data Summary Grid"
  member :chart,       :display => "Chart", :default => true
  member :gis,         :display => "Map"
end

Where:

    * The symbol is main accessor for Elemental
    * Display is what the end-user sees. Display defaults to the symbol's to_s.
    * Position (not represented) is the sort order (use WidgetType.sort...) 
    * Default sort order is the order in which elements are declared (ordinal). 

For Rails, Populate select dropdowns like this:

<p><label for="widget_type">Type</label><br/>
  <%= select "dashboard_widget", "widget_type", 
    WidgetType.sort.map{|wt| [wt.display, wt.value]}, 
    { :include_blank => false, 
      :selected => WidgetType.defaults.first.value } 
  %></select>
</p>

More than one default is supported (dropdowns only use one, so first.value gets you first one, radio buttons or checkboxes can use all defaults). Ordinal position is preserved and traditionally shouldn't be changed during the life of the project, although, Ruby being Ruby and developers saying "Ruby ain't C," an Elemental's elements almost definitely will get changed by some developer at some time. As such, the default behavior for "value" is to return the symbol rather than ordinal value and storing as a string in DB, which seems the safest route to take albeit not the optimal performance-wise (finding records by integral value is faster than string searches, even with indexes in place).  If you want to override this, simply call "persist_ordinal" when you declare your Elemental classes.

class Color < Elemental
  persist_ordinal
  member :red
  member :green
  member :blue
end
  
Comparisons are done with:

widget = Widget.find :first
if widget.color == Color::red.value do
 ...

Elements are accessed multiple ways:

def test_different_retrievals_get_same_element
  a1 = Car::honda
  a2 = Car::Honda
  a3 = Car[:honda]
  a4 = Car[:Honda]
  a5 = Car["Honda"]
  a6 = Car["honda"]
  a7 = Car.first
  a8 = Car.last.succ
  assert_element_sameness(a1, a2, :honda)
  assert_element_sameness(a2, a3, :honda)
  assert_element_sameness(a4, a5, :honda)
  assert_element_sameness(a6, a7, :honda)
  assert_element_sameness(a8, a1, :honda)
end

There are also several convenience aliases to pull ordinal, value, symbol and display:

def test_aliases 
  assert_equal(Car::toyota.index, Car::toyota.to_i)
  assert_equal(Car::toyota.to_i, Car::toyota.to_i)
  assert_equal(Car::toyota.to_int, Car::toyota.to_i)
  assert_equal(Car::toyota.ord, Car::toyota.to_i)
  assert_equal(Car::toyota.ordinal, Car::toyota.to_i)
  assert_equal(Car::toyota.to_sym, Car::toyota.value)
  assert_equal(:toyota, Car::toyota.to_sym)
  assert_equal(:toyota, Car::toyota.value)
  assert_equal("toyota", Car::toyota.display)
  assert_equal("toyota", Car::toyota.humanize)
end

Full test coverage is provided. 

== REQUIREMENTS:

* Ruby 1.8.6+
* Ruby Gems

== INSTALL:

* sudo gem install elemental

== LICENSE:

(The MIT License)

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
