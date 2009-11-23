# ELEMENTAL

Elemental gives you enumerated sets.  You code symbolically,
keeping literals away from your conditional logic.

## REQUIREMENTS:
* Ruby 1.8+
* Ruby Gems

## INSTALL:

Project Hosts:
* [Rubyforge](http://elemental.rubyforge.net)
* [Github](http://github.com/mwlang/elemental/tree/master)

From Gem:

    sudo gem install elemental

From Source:

    gem install bones, rake, test-unit
    git clone git://github.com/mwlang/elemental.git
    cd elemental
    rake gem:package
    cd pkg
    sudo gem install elemental

### Working Examples:
 Check out the projects in the examples folder for working examples of
 using Elemental.  Examples may be limited presently, but more are planned.
 If you have a unique/interesting application of Elemental, please feel free
 to contact me and let me know about it for possible inclusion.

## FEATURES/PROBLEMS:
* Code with symbols, easily display what the user needs to see.
* Associate any number of values/attributes with a symbolic element.
* Change the display values without worrying about logical side-effects.
* Access elements in a variety of ways: symbol, constant, index.
* Store in database as either string (the default) or ordinal value.
* Elemental is also Enumerable.  You can iterate all members and sort, too.
* A default flag can be set that makes it easier to render views.

## DESCRIPTION:
Elemental provides enumerated collection of elements that allow you to associate
ruby symbols to arbitrary "display" values, thus allowing your code to "think"
symbolically and unambiguously while giving you the means to easily display what
end-users need to see. Additionally, symbols are associated with ordinal values,
allowing easy storage/retrieval to persistent stores (databases, files,
marshalling, etc) by saving the Element#value as appropriate (String by default,
Fixnum if you "persist_ordinally").

The primary aim of Elemental is to collect and abstract literals away
from your code logic. There's an old programmer's wisdom that you should not
encode your logic using literal values, especially those the end-user is exposed to.

Yet, interpreted languages seem to be famous for sowing the practice of doing
boolean expressions replete with string literals. Which can be ok until one day
your client says, "I don't like 'Active' can we use 'enabled' instead?").

In your code, instead of:

	if my_user.status == 'Active' ...
	
or worse

	my_user.favorite_color = 1

(what color is 1?!)

The above suffers from the following:
* literals are subject to change or are cryptic.
* diff spellings mean diff things ('Active' != 'active' != 'Actve').
* relying on literals error prone and hard to test.
* code is often not readable as-is (what color is 1, again?).

With Elemental, do this:

	if my_user.status == UserStatus::active.value
	my_user.favorite_color = Color::blue

When you save a value to a persistent store (database, stream, file, etc.), you
assign the Element#value like so:

	my_user.status = UserStatus::active.value

(more on what you get via "value" later)

If UserStatus::active isn't defined, you get an error immediately that you can
attribute to a typo in your code. This behavior is by design in Elemental.
That's a unit test you *don't* have to write! Simply define your class or module
and include the Ruby symbols you need:

	class AccountStatus
		extend Elemental
		member :active,       :display => 'Active'
		member :delinquent,   :display => "Account Past Due"
		member :inactive      :display => "Inactive"
	end

Elemental can return the Element#value as either a Ruby symbol (Symbol) or an
ordinal (Fixnum) value. The default is a Ruby symbol. To override this and
return an ordinal value, use "persist_ordinally" as follows:

	class AccountStatus
		extend Elemental
		persist_ordinally

		member :active,       :display => 'Active'
		member :delinquent,   :display => "Account Past Due"
		member :inactive      :display => "Inactive"
	end

## SYNOPSIS:

Elementals are "containers" for your elements (a.k.a. Ruby symbols).
They are declared like this:

	class AccountStatus
		extend Elemental
		member :active,       :display => 'Active', :default => true
		member :delinquent,   :display => "Account Past Due"
		member :inactive      :display => "Inactive"
	end

	class Fruit
		extend Elemental
		member :orange,       :position => 10
		member :banana,       :position => 5,  :default => true
		member :blueberry,    :position => 15
	end

Where:
* The symbol is main accessor for Elemental
* Display is what the end-user sees. Display defaults to the symbol's to_s.
* Position lets you define a display sort order (use WidgetType.sort...)
* Position defaults to Ordinal value if not given.
* Absent Position, the default sort order is the order in which elements are declared (ordinal).
* Specifying Position does not change Ordinal value.
* An ElementNotFoundError is raised if you try an nonexistent Symbol.

Another example:

	class Color
		extend Elemental
		member :red,      :display "#FF0000"
		member :green,    :display "#00FF00"
		member :blue,     :display "#0000FF"
	end

So you roll with this for a few months and decided you don't like primary colors?
Its simple to change the color constants (in display):

	class Color
		extend Elemental
		member :red,      :display "#AA5555"
		member :green,    :display "#55AA55"
		member :blue,     :display "#5555AA"
	end

Your code logic remains the same because the symbols didn't change!

Once you have your Elemental classes defined, replace your conditionals
that use string literals.

So, instead of:

	if widget.widget_type == "Foo bar"

(where widget is an Activerecord instance and widget_type is an attribute/column)
(mental note: was that "FOO BAR", "foobar", "Foo Bar", "foo bar", or "Foo bar"??)

Do this and be confident:

	if WidgetType[widget.widget_type] == WidgetType::foo_bar

Or shorter:

	if WidgetType[widget.widget_type].is?(WidgetType::foo_bar)

Or shorter, still:

	if WidgetType[widget.widget_type].is?(:foo_bar)

Although Elemental wasn't specifically written for Rails, it is trivial to put to use.  Instead
if creating a new model and migration script and all that, simply establish your Elemental
class definition and then iterate the Elemental to construct your views as appropriate.

With Elemental, simply populate select dropdowns like this:

in your $RAILS_ROOT/config/initializers/constants.rb:

	class AccountStatus
		extend Elemental
		member :active,       :display => 'Active', :default => true
		member :delinquent,   :display => "Account Past Due"
		member :inactive      :display => "Inactive"
	end

Then in your view:

	<p><label for="account_status">Account Status</label><br/>
		<%= select "user", "status",
			AccountStatus.sort.map{|a| [a.display, a.value]},
			{	:include_blank => false,
				:selected => AccountStatus.defaults.first.value }
		%></select>
	</p>

Or render checkboxes with:

	<% Color.sort.each |c| do %>
		<%= check_box_tag("user[favorite_colors][#{c.value}]",
			"1", Color.defaults.detect{|color| color == c}) %>
		<%= "#{c.display}"%><br />
	<% end %>

Life is simplified because:
* No more migrate scripts for tiny tables
* No worries that the auto-incrementer is guaranteeing to assign 
  same ID accross deployments.
* No database penalties looking up rarely changing values
* No worries that an empty lookup table breaks your application logic/flow
* Values that mean something in your app are symbolic while what's displayed 
  and sorted on are free to change as the application grows and evolves.

More than one default is supported (dropdowns only use one, so first.value
gets you first one, radio buttons or checkboxes can use all defaults). Ordinal
position is preserved and traditionally shouldn't be changed during the life
of the project, although, Ruby being Ruby and developers saying "Ruby ain't C,"
an Elemental's elements almost definitely will get changed by some developer at
some time.

The chances of the name of the symbol changing is much lower than a developer's
tendency to keep an orderly house by sorting member elements alphabetically. As
such, the default behavior for "value" is to return the symbol rather than
ordinal value and storing as a string in DB, which seems the safest route to
take albeit not the optimal performance-wise (finding records by integral value
is faster than string searches, even with indexes in place). If you want to
override this, simply call "persist_ordinally" when you declare your Elemental
classes.

	class Color
		extend Elemental
		persist_ordinally
		member :red
		member :green
		member :blue
	end

With that, Color::red.value returns Fixnum 0 instead of the Symbol :red

You can also associate many values with a particular element through custom accessors.  
To extend the Color example further:

	class Color
		extend Elemental
		persist_ordinally
		member :red, :display => "Primary Red", :red => 255, :green => 0, :blue => 0, :hex => "#FF0000"
		member :green, :display => "Primary Green", :red => 0, :green => 255, :blue => 0, :hex => "#00FF00"
		member :blue, :display => "Primary Blue", :red => 0, :green => 0, :blue => 255, :hex => "#0000FF"
	end

With that:

	Color::red.red => 255
	Color::red.green => 0
	Color::red.blue => 0
	Color::red.hex => "#FF0000"

Elements can be accessed multiple ways:

	def test_different_retrievals_get_same_element
		a1 = Car::honda
		a2 = Car::Honda
		a3 = Car[:honda]
		a4 = Car[:Honda]
		a5 = Car["Honda"]
		a6 = Car["honda"]
		a7 = Car.first
		a8 = Car.last.succ
		a9 = Car[0]
		assert_element_sameness(a1, a2, :honda)
		assert_element_sameness(a2, a3, :honda)
		assert_element_sameness(a4, a5, :honda)
		assert_element_sameness(a6, a7, :honda)
		assert_element_sameness(a8, a1, :honda)
		assert_element_sameness(a9, a2, :honda)
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

One known limitation (which is probably a reflection of my not-so-great Ruby skills):

You cannot inherit and Elemental from another Elemental, esp. since none of the classes or
modules are ever actually instantiated.  The following will NOT WORK:

	class Fruit           # OK
		extend Elemental
		member :orange
		member :banana
		member :blueberry
	end

	class Vegetable       # OK
		extend Elemental
		member :potato
		member :carrot
		member :tomato
	end

	class Food            # NOT OK
		extend Fruit
		extend Vegetable
	end

Also, this doesn't work, either:

	class Food < Fruit   # NOT OK
		extend Vegetable
	end

Nor:

	class ExoticFruit < Fruit   # NOT OK
		member :papaya
		member :mango
	end


## LICENSE:

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
