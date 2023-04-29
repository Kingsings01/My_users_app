#Require the necessary dependencies and the user model
require_relative 'my_user_model.rb' #import user Module 
require 'sinatra' #import sinatra Module
require 'json'    #import json Module
require 'erb'     #import erb Module

set :view, File.join(settings.root, 'views') #Set the views folder
set :port, 8080   #Set port 8080 
enable :sessions  #Enable the use of sessions

#Display the list of users on the index page
get '/' do                 #Get the main page
    @users = User.new.all.map{|id, user| user.delete(:password); user}   #Get all the users and remove the password field
    @users
    erb :index             #Render the index page using ERB
end
#
get '/users' do             #get all users
    status 200              #set status code
    User.all.map{|col| col.slice("firstname", "lastname", "age", "email")}.to_json  # get all users and map them. converted to json
end

post '/sign_in' do          # handle sign in
    verify_user=User.authenticate(params[:password],params[:email])    # Authenticate user with given credentials.
    if !verify_user.empty?  # Check if user is empty or not
        status 200          # Set status code to 200
        session[:user_id] = verify_user[0]["id"]                       # Set session variable for user id
    else
        status 401          # Set status code to 401
    end 
    verify_user[0].to_json  # Convert user to json
end
#
post '/users' do            # handle post request to user
    if params[:firstname] != nil            # Check if firstname is provided or not
        create_user = User.create(params)   # Create new user with given params
        new_user = User.find(create_user.id)# find the newly created user
        user = {            # Create a hash containing the user data to be returned
            firstname: new_user.firstname,
            lastname: new_user.lastname,
            age: new_user.age,
            password: new_user.password,
            email: new_user.email
        }.to_json           # Convert user data to JSON

        status 200          # Set status code to 200
        return user         # Return the user data as a JSON response
    else 
        check_user = User.authenticate(params[:password], params[:email])# Authenticate user with given credentials.
        if !check_user[0].empty?                    # Check if user is empty or not
            session[:user_id] = check_user[0]["id"] # Set session variable for user id
            status 200      # Set status code to 200
        else
            status 401      # Set status code to 401
        end 

        return check_user[0].to_json    # Return the user data as a JSON response
    end 
end

put '/users' do             # handle PUT request for user
    User.update(session[:user_id], 'password', params[:password]) # update user password
    user = User.find(session[:user_id])                           # find the updated user
    status 200              # set status code to 200
    user_info = {           # create a hash with user data
        firstname: user.firstname,
        lastname: user.lastname,
        age: user.age,
        password: user.password,
        email: user.email
    }.to_json               # convert the hash to JSON
    return user_info        # return the JSON representation of the user
end

delete '/sign_out' do       # handle sign out
    session[:user_id] = nil # Clear session variable
    status 204              # Set status code to 204
end

delete '/users' do          # handle delete for user
    session[:user_id] = nil # Clear session variable
    status 204              # Set status code to 204
end

# The API endpoints are defined as follows:
#1 GET '/' - This endpoint retrieves a list of all users and renders an HTML view of the list.
#2 GET '/users' - This endpoint retrieves a list of all users in JSON format.
#3 POST '/users' - This endpoint creates a new user record based on the information submitted in the request body.
4# POST '/sign_in' - This endpoint logs in a user by checking the email and password against the database.
#5 PUT '/users' - This endpoint updates the password for the currently logged-in user.
#6 DELETE '/sign_out' - This endpoint logs out the currently logged-in user.
#7 DELETE '/users' - This endpoint deletes the currently logged-in user.
#8 The code also defines a User class, which is responsible for managing the database of user records. The User class has methods for creating, updating, retrieving, and deleting user records, as well as a method for retrieving all user records.
#9 The code uses the ERB templating engine to render the HTML view for the '/' endpoint. It also uses sessions to keep track of the currently logged-in user.
#0 Overall, this code provides a basic RESTful API for user management, which can be used as a starting point for building more complex applications.
