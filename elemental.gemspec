Gem::Specification.new do |s|
  s.name     = "elemental"
  s.version  = "0.1.1"
  s.date     = "2009-06-03"
  s.summary  = "Implements a set of elements that are enumerable."
  s.email    = "mwlang@cybrains.net"
  s.homepage = "http://github.com/mwlang/elemental"
  s.description = "Elemental provides enumerated set of elements allowing your code to think symbolically and unambiguously while giving you the means to easily display what end-users need to see."
  s.has_rdoc = true
  s.authors  = ["Michael Lang"]
  s.platform = Gem::Platform::RUBY
  s.files    = [ 
		"elemental.gemspec", 
		"README.txt",
		"Rakefile",
		"lib/element.rb",
		"lib/elemental.rb",
		"test/test_elemental.rb"
	]
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Elemental", "--main", "README.txt"]
  s.extra_rdoc_files = ["README.txt"]
end

