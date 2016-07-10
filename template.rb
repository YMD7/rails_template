#
# template.rb
#

# .gitignore
run 'gibo OSX Ruby Rails Vim SublimeText > .gitignore' rescue nil
gsub_file '.gitignore', /^config\/initializers\/secret_token.rb\n/, ''
gsub_file '.gitignore', /^config\/secrets.yml\n/, ''
insert_into_file '.gitignore', <<GIT, after: 'Rails.gitignore'

.env
GIT

# Gemfile
gsub_file 'Gemfile', /#.+\n/, ''
gsub_file 'Gemfile', /^$\n{2,}/, "\n"

gem 'thor'
gem 'unicorn'
gem 'dotenv-rails'
gem 'devise'
gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-facebook'
gem 'slim-rails'
gem 'bourbon'
gem 'neat'
gem 'bitters'
gem "font-awesome-rails"

gem_group :development do
  gem 'html2slim'
end

gem_group :development, :test do
  gem 'pry-rails'
  gem 'pry-doc'
  gem 'pry-remote' # bundle exec pry-remote
  gem 'pry-stack_explorer'
end

# install gems
run 'bundle install'

# dotenv
create_file '.env', <<DOTENV
# .env
DOTENV

# devise
insert_into_file 'config/environments/development.rb', <<RUBY, after: 'config.assets.debug = true'

  # devise
  config.action_mailer.default_url_options = { host: 'localhost:3000' }
RUBY

generate 'devise:install'
generate 'devise:views'
generate 'devise User'
generate 'migration add_columns_to_users provider uid username'

insert_into_file 'app/models/user.rb', <<RUBY, after: ":validatable"
,
         :confirmable, :lockable, :timeoutable, :omniauthable,
         omniauth_providers: [:facebook]
RUBY

insert_into_file 'config/initializers/devise.rb', <<RUBY, after: "# ==> OmniAuth"
   config.omniauth :facebook, ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET']
RUBY

# convert erb file to slim
run 'bundle exec erb2slim -d app/views'

# app/assets/javascripts
create_file 'app/assets/javascripts/application.js', <<JS, force: true
//= require jquery
//= require turbolinks
//= require_tree .
JS

# make directory structure as like FLOCSS
run 'mkdir app/assets/stylesheets/foundation/'
run 'mkdir app/assets/stylesheets/layout/'
run 'mkdir app/assets/stylesheets/object/component/'
run 'mkdir app/assets/stylesheets/object/project'
run 'mkdir app/assets/stylesheets/object/utility'

# install bourbon/bitters
run 'bitters install --path=app/assets/stylesheets/foundation/'

# install normalize.css
<<<<<<< HEAD
run 'curl https://raw.githubusercontent.com/necolas/normalize.css/master/normalize.css > app/assets/stylesheets/foundation/normalize.css'
=======
run 'curl https://raw.githubusercontent.com/necolas/normalize.css/master/normalize.css > app/assets/stylesheets/foundation/'
>>>>>>> origin/master

# app/assets/stylesheets
create_file 'app/assets/stylesheets/application.scss', <<SCSS, force: true
// ==========================================================================
// Foundation
// ==========================================================================

@import "foundation/_normalize";
@import "bourbon";
@import "neat";
@import "foundation/base/base";
@import "font-awesome";

// ==========================================================================
// Layout
// ==========================================================================

// @import "layout/";

// ==========================================================================
// Object
// ==========================================================================

// -----------------------------------------------------------------
// Component
// -----------------------------------------------------------------

// @import "object/component/";

// -----------------------------------------------------------------
// Project
// -----------------------------------------------------------------

// @import "object/project/";

// -----------------------------------------------------------------
// Utility
// -----------------------------------------------------------------

// @import "object/utility/";
SCSS

# DB migration
rake 'db:migrate'

# lib/tasks/unicorn.rake
create_file 'lib/tasks/unicorn.rake', <<RAKE
namespace :unicorn do
  ##
  # Tasks
  ##
  desc "Start unicorn for development env."
  task(:start) {
    config = Rails.root.join('config', 'unicorn.rb')
    sh "bundle exec unicorn_rails -c \#{config} -E development -D"
  }

  desc "Stop unicorn"
  task(:stop) { unicorn_signal :QUIT }

  desc "Restart unicorn with USR2"
  task(:restart) { unicorn_signal :USR2 }

  desc "Increment number of worker processes"
  task(:increment) { unicorn_signal :TTIN }

  desc "Decrement number of worker processes"
  task(:decrement) { unicorn_signal :TTOU }

  desc "Unicorn pstree (depends on pstree command)"
  task(:pstree) do
    sh "pstree '\#{unicorn_pid}'"
  end

  def unicorn_signal signal
    Process.kill signal, unicorn_pid
  end

  def unicorn_pid
    begin
      File.read("tmp/unicorn.pid").to_i
    rescue Errno::ENOENT
      raise "Unicorn doesn't seem to be running"
    end
  end

end
RAKE

# config/unicorn.rb
create_file 'config/unicorn.rb', <<UNICORN
# -*- coding: utf-8 -*-
rails_root = File.expand_path('../../', __FILE__)

worker_processes 2
working_directory rails_root

listen "\#{rails_root}/tmp/unicorn.sock"
pid "\#{rails_root}/tmp/unicorn.pid"

stderr_path "\#{rails_root}/log/unicorn_error.log"
stdout_path "\#{rails_root}/log/unicorn.log"

UNICORN

# make design folder
Dir.mkdir 'design'

# remove files
remove_file 'app/assets/stylesheets/application.css'

# pristine
run 'gem pristine --all'

# git
git :init
git add: '.'
git commit: "-m 'Initial commit'"

