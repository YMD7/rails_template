#
# template.rb
#

# .gitignore
run 'gibo OSX Ruby Rails Vim SublimeText > .gitignore' rescue nil

# Gemfile

gsub_file 'Gemfile', /#\w+\n/, ''

gem_group :default do
  gem 'slim-rails'
end
