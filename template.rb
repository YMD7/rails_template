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
@import "./*";
SCSS

create_file 'app/assets/stylesheets/layout.scss', <<LAYOUT
@charset "utf-8";

// -- + import + -------------
@import "variables.scss";

// ==========================================================================
//
//  ++ general ++
//
// ==========================================================================

// --------------------------------
//                     + reset +
// --------------------------------
html, body,
h1, h2, h3, h4, h5,
p, a {
  margin: 0;
  color: $default_color;
  font-family: $default_font;
  text-decoration: none;
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

# design folder
Dir.mkdir 'design'

# remove files
remove_file 'app/assets/stylesheets/application.css'

# pristine
run 'gem pristine --all'

# git
git :init
git add: '.'
git commit: "-m 'Initial commit'"

