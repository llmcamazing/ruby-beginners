require 'sinatra'
require 'data_mapper'
require 'dm-sqlite-adapter'

# For this lesson to work you must have all three gems above installed.

# Models
# ******
# The following loads the models directory.
# We're going to use this to create a user model.

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/models")
Dir.glob("#{File.dirname(__FILE__)}/models/*.rb") { |model| require File.basename(model, '.*') }

# Database path
# *************
# This next line sets up a local sqlite database file for working with data.
# It also defaults to a DATABASE_URL first -- this is for use with Heroku.
# Note that if you want to use sqlite, you need the datamapper sqlite adapter gem,
# and if you're deploying to Heroku you need the datamapper postgres adapter gem.

DataMapper.setup(:default, (ENV["DATABASE_URL"] || "sqlite3:///#{File.expand_path(File.dirname(__FILE__))}/#{Sinatra::Base.environment}.db"))

# Session Cookie
# **************
# the following line of code enables a session cookie,
# so that you can keep track of your user

enable :sessions

# Templates
# *********
# Sinatra assumes that templates are in the views folder.
# The following can be deleted, UNLESS
# you plan to use a different path for templates.
# Check Section 3: Views/Templates in the Sinatra Intro for reference:
# http://www.sinatrarb.com/intro

configure do
	set :views, "#{File.dirname(__FILE__)}/views"
end

# Filters
# *******
# Anything in the before block is run every time a user goes to a route.
before do
# This sets up a @user instance variable by getting
# the user's ID from the session cookie.
# ( More about this farther down )
	@user = User.get(session[:id])
end

# Here's our index, nothing to see here, move along...

get '/' do
  erb :index
end

# This is a basic login route. Gotta have that login template!

get '/login/?' do
	erb :login
end

# Dealing with login POST data
# ****************************
# params is a hash variable available to you in every route.
# It contains the data that's been sent by the user,
# and formatted according to your specifications

post '/login/?' do
	user = User.first :name => params[:name]

# Above, we're getting the name parameter sent to us
# by the form set up inside of login.erb.

# Below we're checking with the database
# to see if the password matches the username in the database.

	if user and user.password == params[:password]
	  
# If everything goes well, we clear the session cookie
# and set the session ID to the current user's ID,
# then send them back to the index.
	  
		session.clear
		session[:id] = user.id
		redirect '/'
		
# If the credentials don't match,
# we send them back to the login page with an error message.
# An image of Mr. T is optional.

	else
		erb :login, :locals => { :error_msg => '<img src="http://1.bp.blogspot.com/_u9ZV5UkERTE/S9BKXlsYiUI/AAAAAAAAAFc/kFnd6Naz02Q/s1600/MrT15.jpg" width="100" height="100"> I pity the fool who uses invalid login credentials.' }
	end
end


# logout route
# ************
# This is pretty simple:
# If someone goes to the logout route, there session cookie is cleared.
# If you want to get fancy you can create a confirmation dialog
# That sends to an extra route, or uses POST data to confirm and
# clear the session cookie.

get '/logout/?' do
	session.clear
	redirect '/'
end


# This last block is a bit of a cheat to create a default user
# without setting up a console interface with our Sinatra app.
# ******* WARNING *******
# DO NOT do anything like this on a production app. It's very bad.

get '/database/test/?' do

# Next we create the database -- destructively.
# This command wipes out any pre-existing database. Use it wisely.

  DataMapper.auto_migrate!

# Now we create a default user and send a message to the user.

  @user = User.create(
    :name       => "admin",
    :password       => "admin"
  )
  
  'Database Created.'
  
end

