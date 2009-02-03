# Each Error Message is turned into a sub-class of its respective Elemental class.
#   For example, ProgrammersErrorMessages[:abstract_method] is loaded as:
#     AbstractMethodError exception class,
#     which is, in turn, derived from ProgrammersError class.
#
# This is a powerful concept simply because you can now separate display and behavior of the
# message from the definition of the messages themselves.  Alternatively, you can extend these
# to support internationalization of the messages themselves.

require 'rubygems'
require 'active_support'
require 'elemental'

class ProgrammersErrorMessages
  extend Elemental
  member :unspecified_programmers,   :display => "An unspecified error occurred."
  member :abstract_method,           :display => "Called an abstract method."
  member :invalid_field_passed,      :display => "Invalid field was passed in arguments."
end

class ProgrammersError < RuntimeError
  def message_name
    result = self.class.to_s.gsub("Error",'').underscore
    result == "programmers" ? ProgrammersErrorMessages.first.to_s : result
  end

  def message
    "Programmer's Error: " + ProgrammersErrorMessages[message_name].display + " (#{super})"
  end
end

# Creates the descendant error classes, one for each member defined in ProgrammersErrorMessages
ProgrammersErrorMessages.each{|msg| eval("class #{msg.to_s.titleize.gsub(' ','')}Error < ProgrammersError; end")}
