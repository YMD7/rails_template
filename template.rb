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

# app/assets/javascripts
create_file 'app/assets/javascripts/application.js', <<JS, force: true
//= require jquery
//= require turbolinks
//= require_tree .
JS

# app/assets/stylesheets
create_file 'app/assets/stylesheets/application.scss', <<SCSS, force: true
@import "bourbon";
@import "neat";
@import "common/*";
@import "partial/*";
SCSS

Dir.mkdir 'app/assets/stylesheets/common/'

create_file 'app/assets/stylesheets/common/_layout.scss', <<LAYOUT
@charset "utf-8";

LAYOUT

create_file 'app/assets/stylesheets/common/_variables.scss', <<VARIABLES
@charset "utf-8";

VARIABLES

create_file 'app/assets/stylesheets/common/_neat_variables.scss', <<NEAT
@charset "utf-8";

NEAT

create_file 'app/assets/stylesheets/common/_refills.scss', <<REFILLS
@charset "utf-8";

REFILLS

Dir.mkdir 'app/assets/stylesheets/partial/'

# DB migration
rake 'db:migrate'

# remove files
remove_file 'app/assets/stylesheets/application.css'

# pristine
run 'gem pristine --all'

# git
git :init
git add: '.'
git commit: "-m 'Initial commit'"

