require 'error_messages'

puts "Example of raising an unspecified error...\n"
puts "Pick an error to raise:"

ProgrammersErrorMessages.each_with_index { |p, index| puts "     #{index + 1}. #{p.display}" }

printf "choice [1..#{ProgrammersErrorMessages.size}]:  "
error_to_raise = gets

if error_to_raise.to_i >= 1 and error_to_raise.to_i <= ProgrammersErrorMessages.size
  case error_to_raise.to_i
    when 1 then raise UnspecifiedProgrammersError
    when 2 then raise AbstractMethodError
    when 3 then raise InvalidFieldPassedError
  end
else
  raise ProgrammersError
end
