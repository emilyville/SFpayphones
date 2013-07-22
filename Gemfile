source 'https://rubygems.org'
ruby '1.9.3', engine: 'jruby', engine_version: '1.7.4'
gem 'rails', '4.0.0'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'
# heroku id is shielded-coast-8367.git

group :development, :test do
	gem 'jdbc-sqlite3'
	gem 'activerecord-jdbcsqlite3-adapter', '1.3.0.beta2'
end
group :production do
	gem 'jdbc-postgres'
	gem 'activerecord-jdbcpostgresql-adapter', '1.3.0.beta2'
end

gem 'jquery-rails'
gem 'twilio-ruby'
gem 'figaro'
gem 'google-webfonts'
gem 'sass-rails'
gem 'coffee-rails'
gem 'uglifier'
gem 'puma'
gem 'redis'
# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'
