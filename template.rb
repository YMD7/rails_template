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

gem_group :development do
  gem 'html2slim'
end

gem_group :development, :test do
  gem 'pry-rails'
  gem 'pry-doc'
  gem 'pry-byebug'
  gem 'pry-stack_explorer'
end

# install gems
run 'bundle install'

# convert erb file to slim
run 'bundle exec erb2slim -d app/views'

# DB migration
rake 'db:migrate'

# git
git :init
git add: '.'
git commit: "-m 'Initial commit'"

