#
# template.rb
#

# .gitignore
run 'gibo OSX Ruby Rails Vim SublimeText > .gitignore' rescue nil

# Gemfile
gsub_file 'Gemfile', /#.+\n/, ''
gsub_file 'Gemfile', /^$\n{2,}/, "\n"

gem 'unicorn'
gem 'devise'
gem 'slim-rails'
gem 'bourbon'
gem 'neat'

group :development, :test do
  gem 'pry-rails'
  gem 'pry-doc'
  gem 'pry-byebug'
  gem 'pry-stack_explorer'
end
