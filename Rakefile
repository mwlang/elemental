# Look in the tasks/setup.rb file for the various options that can be
# configured in this Rakefile. The .rake files in the tasks directory
# are where the options are used.

begin
  require 'bones'
  Bones.setup
rescue LoadError
  begin
    load 'tasks/setup.rb'
  rescue LoadError
    raise RuntimeError, '### please install the "bones" gem ###'
  end
end

ensure_in_path 'lib'
require 'elemental'

task :default => 'test:run'

PROJ.name = 'elemental'
PROJ.authors = 'Michael Lang'
PROJ.email = 'mwlang@cybrains.net'
PROJ.url = 'FIXME (project homepage)'
PROJ.version = Elemental::VERSION
PROJ.rubyforge.name = 'elemental'

PROJ.spec.opts << '--color'

# EOF
