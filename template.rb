#
# template.rb
#

# .gitignore
run 'gibo OSX Ruby Rails Vim SublimeText > .gitignore' rescue nil

# Gemfile
gsub_file 'Gemfile', /#.+\n/, ''
gsub_file 'Gemfile', /^$\n{2,}/, \n

gem_group :default do
  gem 'slim-rails'
end
