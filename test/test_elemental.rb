#!/usr/bin/env ruby

require 'test/unit'
require 'lib/elemental'

module TestElemental

  class TestElemental < Test::Unit::TestCase

    class Fruit
      extend Elemental
      member :apple
      member :pear, :default => true
      member :banana, :default => true
      member :kiwi

      synonym :machintosh, :apple
    end

    FRUIT_SIZE = 4

    class Color
      extend Elemental
      member :blue, :display => "Hazel Blue", :default => true
      member :red, :display => "Fire Engine Red"
      member :yellow
    end

    COLOR_SIZE = 3

    class Car
      extend Elemental
      member :honda, :position => 100
      member :toyota, :position => 30
      member :ford, :position => 50
      member :gm, :position => 25
      member :mazda, :position => 1
    end

    CAR_SIZE = 5

    class JumbledMess
      extend Elemental
      member :testing
      member :Oh_one
      member :two_three
      member :FourFiveSix
      member :what_an_id
      member :your_idea
    end

    class TalkingNumbers
      extend Elemental
      persist_ordinally
      member :zilch
      member :uno
      member :dos
      member :tres
    end

    def test_values_as_ordinal
      one = TalkingNumbers[:uno]
      two = TalkingNumbers["dos"]
      three = TalkingNumbers[3]

      assert_equal(one.to_i, one.value)
      assert_equal(2, two.value)
      assert_equal(3, three.value)
    end

    def test_humanize
      assert_equal("Testing", JumbledMess::testing.humanize)
      assert_equal("Oh one", JumbledMess::oh_one.humanize)
      assert_equal("Two three", JumbledMess::two_three.humanize)
      assert_equal("Four five six", JumbledMess::FourFiveSix.humanize)
    end

    # Test the order of breadth for each
    def test_size_of_elemental
      assert_equal(FRUIT_SIZE, Fruit.size)
      assert_equal(COLOR_SIZE, Color.size)
      assert_equal(CAR_SIZE, Car.size)
    end

    def assert_can_map_elements
      assert_not_nil(Car.collect{|c| c.value})
    end

    def assert_element_sameness(a, b, symbol)
      assert_not_nil(a)
      assert_not_nil(b)
      assert(a.is_a?(Element))
      assert(b.is_a?(Element))
      assert_equal(a, b)
      assert_equal(symbol, a.to_sym)
      assert_equal(symbol, b.to_sym)
      assert_equal(a, b)
    end

    def test_basic_retrieval
      assert_not_nil(Fruit::apple)
      assert_not_nil(Fruit::banana)
      assert_not_nil(Fruit::pear)
      assert_not_nil(Fruit::kiwi)
    end

    def test_jumbled_retrival
      assert_not_nil(JumbledMess::testing)
      assert_not_nil(JumbledMess::two_three)
      assert_not_nil(JumbledMess::what_an_id)
      assert_not_nil(JumbledMess::your_idea)
      assert_not_nil(JumbledMess::oh_one)
      assert_not_nil(JumbledMess["oh_one"])

      assert_not_nil(JumbledMess::Oh_one)
      assert_not_nil(JumbledMess::Oh_One)
      assert_not_nil(JumbledMess::FourFiveSix)
      assert_not_nil(JumbledMess::Four_Five_six)
    end

    def test_basic_nonretrieval
      assert_raise(RuntimeError) { Fruit::tomato }
      assert_raise(RuntimeError) { Fruit::Potato }
      assert_raise(RuntimeError) { Fruit[:squash] }
      assert_raise(RuntimeError) { Fruit["okra"] }
      assert_raise(RuntimeError) { Fruit[10] }
    end

    def test_retrieval_by_ordinal
      apple1 = Fruit[0]
      apple2 = Fruit.select{|s| s.to_sym == :apple}.first
      assert_element_sameness(apple1, apple2, :apple)

      pear1 = Fruit[1]
      pear2 = Fruit[:pear]
      assert_element_sameness(pear1, pear2, :pear)

      kiwi1 = Fruit[-1]
      kiwi2 = Fruit.last
      assert_element_sameness(kiwi1, kiwi2, :kiwi)
    end

    def test_retrieval_by_symbol
      a1 = Fruit::apple
      a2 = Fruit[:apple]
      a3 = Fruit.select{|s| s.to_sym == :apple}.first
      assert_element_sameness(a1, a2, :apple)
      assert_element_sameness(a1, a3, :apple)
      assert_element_sameness(a2, a3, :apple)

      b1 = Fruit::banana
      b2 = Fruit[:banana]
      b3 = Fruit.select{|s| s.to_sym == :banana}.first
      assert_element_sameness(b1, b2, :banana)
      assert_element_sameness(b1, b3, :banana)
      assert_element_sameness(b2, b3, :banana)
    end

    def test_retrieval_by_constant
      a1 = Car::Toyota
      a2 = Car[:Toyota]
      a3 = Car.select{|s| s.to_sym == :toyota}.first
      assert_element_sameness(a1, a2, :toyota)
      assert_element_sameness(a1, a3, :toyota)
      assert_element_sameness(a2, a3, :toyota)
    end

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

    def test_get_first_element
      e1 = Color.first
      e2 = Color::blue
      assert_element_sameness(e1,e2,:blue)
      assert_equal(e1.to_i, 0)
      assert_equal(e1.to_i, e2.ord)
      assert_equal(e2.ordinal, 0)
    end

    def test_walk_succ
      e1 = Color.first
      assert_element_sameness(e1, Color::blue, :blue)
      assert_equal(0, e1.ordinal)
      e1 = e1.succ
      assert_element_sameness(e1, Color::red, :red)
      assert_equal(1, e1.ordinal)
      e1 = e1.succ
      assert_element_sameness(e1, Color::yellow, :yellow)
      assert_equal(2, e1.ordinal)
      e1 = e1.succ
      assert_element_sameness(e1, Color::blue, :blue)
      assert_equal(0, e1.ordinal)
    end

    def test_get_last_element
      e1 = Color.last
      e2 = Color::yellow
      assert_element_sameness(e1,e2,:yellow)
      assert_equal(e1.to_i, COLOR_SIZE - 1)
      assert_equal(e1.to_i, e2.ord)
      assert_equal(e2.ordinal, COLOR_SIZE - 1)
    end

    def test_walk_pred
      e1 = Color.first
      assert_element_sameness(e1, Color::blue, :blue)
      assert_equal(0, e1.ordinal)

      e1 = e1.pred
      assert_element_sameness(e1, Color::yellow, :yellow)
      assert_equal(2, e1.ordinal)

      e1 = e1.pred
      assert_element_sameness(e1, Color::red, :red)
      assert_equal(1, e1.ordinal)

      e1 = e1.pred
      assert_element_sameness(e1, Color::blue, :blue)
      assert_equal(0, e1.ordinal)
    end

    def test_get_as_array
      a = Color.to_a
      assert(a.is_a?(Array))
      assert_equal(COLOR_SIZE, a.size)
      assert(a.first.is_a?(Element))
      assert_element_sameness(Color.first, a.first, :blue)
      assert_element_sameness(Color.first.succ, a[1], :red)
    end

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
      assert_equal("Toyota", Car::toyota.humanize)
    end

    def test_to_a_gives_elements_in_ordinal_position
      a = Color.to_a
      assert(a.is_a?(Array))
      assert_equal(COLOR_SIZE, a.size)
      assert(a.first.is_a?(Element))
      a.each_with_index do |element, index|
        assert_equal(index, element.ordinal)
      end
    end

    def test_each_gives_elements_in_ordinal_position
      Car.each_with_index do |element, index|
        assert_equal(index, element.ordinal)
      end
    end

    def test_sorted_by_position_is_equal_to_ordinal_when_position_not_specified
      a = Color.to_a
      b = Color.sort
      assert(b.is_a?(Array))
      assert_equal(COLOR_SIZE, b.size)
      assert(b.first.is_a?(Element))

      # Position (and thus order) should be same as ordinal order when position not specified at creation
      a.each_with_index do |element, index|
        assert_element_sameness(element, b[index], element.to_sym)
      end

      Color.sort.each_with_index do |element, index|
        assert_element_sameness(element, b[index], element.to_sym)
      end
    end

    def test_can_use_map
      Car.map{|m| assert(m.is_a?(Element))}
    end

    def test_equality
      assert_equal(:mazda, Car::mazda.value)
      assert_equal(:mazda, Car::mazda.to_sym)
    end

    def test_sorted_by_position_is_different_than_ordinal_order
      a = Car.to_a
      b = Car.sort
      assert(b.is_a?(Array))
      assert_equal(CAR_SIZE, b.size)
      assert(b.first.is_a?(Element))
      assert_element_sameness(Car::mazda, b.first, :mazda)
      assert_element_sameness(Car::honda, b.last, :honda)

      # Position (and thus order) should be same as ordinal order when position not specified at creation
      a.each_with_index do |element, index|
        assert_not_equal(b[index], element)
      end

      def test_sorted_by_position_is_ascending_by_position
        b = Car.sort
        last_ordinal = -1
        b.each_with_index do |element, index|
          assert(last_ordinal < element.ordinal)
          last_ordinal = element.ordinal
        end
      end
    end

    def test_display_can_be_set
      assert_equal("yellow", Color::yellow.to_s)
      assert_equal("yellow", "#{Color::yellow}")
      assert_equal("yellow", Color::yellow.display)

      a = Color::blue
      assert_equal("Hazel Blue", a.display)
      assert_equal("blue", "#{a}")

      assert_equal("Fire Engine Red", Color::red.display)
    end

    def test_setting_display_does_not_affect_symbol_to_string
      a = Color::blue
      assert_equal("Hazel Blue", a.display)
      assert_equal("blue", "#{a}")
      assert_not_equal("Hazel Blue", a.to_s)
    end

    def test_default_is_false_by_default
      Car.each{|c| assert_equal(false, c.default?)}
    end

    def test_banana_is_default
      assert_equal(true, Fruit::banana.default?)
    end

    def test_can_get_array_of_defaults
      a = Fruit.defaults
      b = [Fruit::banana, Fruit::pear]
      assert_equal(2, a.size)
      assert_equal(2, b.size)
      b.each{|element| assert(a.include?(element), "a, #{a.inspect} does not contain #{element.inspect}")}
    end

    def test_defaults_is_only_defaults
      a = [Fruit::banana, Fruit::pear]
      c = Fruit.reject{|r| a.include?(r)}
      assert_equal(2, a.size)
      assert_equal(FRUIT_SIZE - 2, c.size)
      c.each{|element| assert(!a.include?(element), "a, #{a.inspect} should not contain #{element.inspect}")}
    end

    def test_is_conditional
      assert_equal(true, Fruit::banana.is?(:banana))
      assert_equal(true, Fruit::banana.is?(Fruit::banana))
      assert_equal(false, Fruit::banana.is?(:kiwi))
      assert_equal(true, TalkingNumbers[1].is?(:uno))
      assert_equal(true, TalkingNumbers[2].is?("dos"))
      assert_equal(true, TalkingNumbers["tres"].is?(3))
    end

    def test_synonym_accessor
      a = Fruit::apple
      b = Fruit::machintosh
      assert_equal(a, b)
    end
  end
end
