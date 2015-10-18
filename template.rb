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

# dotenv
create_file '.env', <<DOTENV,
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

gsub_file Dir.glob("db/migrate/**_devise_create_users.rb").first, /(?<!#)#\s/, ''

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
@import "./*";
SCSS

create_file 'app/assets/stylesheets/layout.scss', <<LAYOUT
@charset "utf-8";

// -- + import + -------------
@import "variables.scss";

// -- + include media snippet + -------------
// @include media($mobile) {}

// ==========================================================================
//
//  ++ general ++
//
// ==========================================================================

// --------------------------------
//                     + reset +
// --------------------------------
html, body {
  height: 100%;
}
html, body,
h1, h2, h3, h4, h5,
p, a {
  margin: 0;
  color: $default_color;
  font-family: $default_font;
  text-decoration: none;
  line-height: 100%;
}
h1, h2, h3, h4, h5 {
  font-weight: normal;
}


// --------------------------------
//                     + global class +
// --------------------------------
.hidden {
  display: none !important;
}


// --------------------------------
//                     + bourbon +
// --------------------------------

// -- + neat + -------------

// -- + refills + -------------



// ==========================================================================
//
//  ++ header ++
//
// ==========================================================================



// ==========================================================================
//
//  ++ main ++
//
// ==========================================================================



// ==========================================================================
//
//  ++ footer ++
//
// ==========================================================================



LAYOUT

create_file 'app/assets/stylesheets/variables.scss', <<VARIABLES
@charset "utf-8";

// -- + devise breakpoint + -------------
$desktop: new-breakpoint(min-width 880px 12);
$tablet:  new-breakpoint(min-width 768px 12);
$mobile:  new-breakpoint(max-width 750px 12);

// -- + typography + -------------
$default_color: #000;
$jp_gothic: "Hiragino Kaku Gothic Pro", "ヒラギノ角ゴ Pro W3", メイリオ, Meiryo, $helvetica;
$jp_mincho: "Hiragino Mincho Pro", "ヒラギノ明朝 Pro W3", 游明朝, YuMincho, HG明朝E, $georgia;
$default_font: $jp_gothic;

// -- + color + -------------

// -- + size + -------------

// -- + function + -------------

VARIABLES

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

