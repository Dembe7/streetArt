require 'sinatra' # web framework / crud apps
require 'sinatra/reloader'
require 'pg' # need functions to talk to the db
require 'bcrypt'

# require_relative 'public/main.css'

enable :sessions

def db_query(sql, params = [])
  conn = PG.connect(dbname: 'streetart')
  result = conn.exec_params(sql, params) #always returns array
  conn.close

  return result
end


def logged_in?()
  if session[:user_id]
    return true
  else 
    return false
  end
end

def current_user()
  sql = "select * from users where id = #{ session[:user_id] };"
  user = db_query(sql).first
  return OpenStruct.new(user)
end

get '/' do

  conn = PG.connect(ENV['DATABASE_URL'] || {dbname: 'streetart'})  sql = 'select * from userpost order by title;'
  result = conn.exec(sql) # array of hashes of dishes [{}, {}]
  conn.close
  erb :index, locals: {userpost: result}
end

get '/streetart/new' do
  erb(:new)

end


get '/streetart/:id'  do
  title = params['id']

  conn = PG.connect(ENV['DATABASE_URL'] || {dbname: 'streetart'})

  sql = "select * from userpost where id = #{title};"

  result = conn.exec(sql)[0] 
  # return result.to_a.to_s 
  #pg will always return array
  # return sql

  # userpost = result[0]
  conn.close
  erb(:show, locals:
  {userpost: result} )
end 



post '/streetart/new' do


  sql = "INSERT INTO userpost (image_url, location, user_art, caption, title) values ('#{params['image_url']}','#{params['location']}','#{current_user.id}','#{params['caption']}','#{params['title']}');"

  
  
  conn = PG.connect(ENV['DATABASE_URL'] || {dbname: 'streetart'})
  conn.exec(sql)
  conn.close

  redirect '/'

end

delete '/streetart/:id' do
  sql = "delete from userpost where id = #{ params['id'] };"
  conn = PG.connect(ENV['DATABASE_URL'] || {dbname: 'streetart'})
  conn.exec(sql)
  conn.close
  redirect '/'
end

get '/streetart/:id/edit' do

  # sql = "select * from dishes where id = $1;"
  # dish = db_query(sql, [params['id']]).first

  sql = "select * from userpost where id = #{params['id']};"

  conn = conn = PG.connect(ENV['DATABASE_URL'] || {dbname: 'streetart'})
  result = conn.exec(sql) # [{ 'name' => 'cake', 'image_url' => 'cake.jpg'}]

  result = conn.exec(sql)[0] 
  conn.close


  erb(:edit, locals: { userpost: result })
end



post '/streetart/:id' do

  sql = "update userpost set 
  image_url = '#{params['image_url']}',
  location = '#{params['location']}', 
  caption = '#{params['caption']}', 
  title = '#{params['title']}';"

 conn = PG.connect(ENV['DATABASE_URL'] || {dbname: 'streetart'})
  conn.exec(sql)
  conn.close
  # redirect "/streetart/#{params['id']}"

  redirect "/streetart/#{params['id']}"
  # "hello world"
end


get '/login' do
  erb :login
end

post '/session' do

  # check with the database

  email = params["email"]
  password = params["password"]
  # email
  # loook up the email in the database
  conn = PG.connect(ENV['DATABASE_URL'] || {dbname: 'streetart'})
  sql = "select * from users where email = '#{email}';"
  result =  conn.exec(sql) #
  conn.close

  # if the user exists in db and the password is correct 
  if result.count > 0 && BCrypt::Password.new(result[0]['password_digest']) == password

    # single source of truth
    # you are guarenteed the most up to date data
    #that's why we are only writing down the id in the session
    #write down this user is logged in
    #single user
    session[:user_id] = result[0]['id']
    # its a hash / session for a single user
    # return session[:user_id]
    #then redirect to home route
    redirect '/'
  else 
    erb :login
  end
  end

  get '/signup' do
    erb :signup
  end

  post '/signup' do
    # check with the database
    name = params["name"]
    email = params["email"]
    password = params["password"] 


    password_digest = BCrypt::Password.create(password)

    # email
    # loook up the email in the database
    conn = PG.connect(ENV['DATABASE_URL'] || {dbname: 'streetart'})
    sql = "INSERT INTO users (name, email, password_digest) values('#{params['name']}','#{params['email']}', '#{password_digest}');"
    result =  conn.exec(sql) #
    conn.close
  
    # if the user exists in db and the password is correct 
    # if result.count > 0 && BCrypt::Password.new(result[0]['password_digest']) == password
  
      # single source of truth
      # you are guarenteed the most up to date data
      #that's why we are only writing down the id in the session
  
      #write down this user is logged in
      #single user
      # session[:user_id] = result[0]['id'] 
      # its a hash / session for a single user
  
      #then redirect to home route
      redirect '/'
    # else 
    #   erb :login
    # end
  end

    delete '/session' do 
      
      session[:user_id] = nil

      redirect '/'
    
    end



 get '/mypost' do
  erb :myposts
  # , locals: {userpost: result}
  

end

post 'mypost' do

  conn = PG.connect(ENV['DATABASE_URL'] || {dbname: 'streetart'})
  sql = "select * from userposts where user_art  = #{current_user.id};"
  result = conn.exec(sql) # array of hashes of dishes [{}, {}]
  return sql
  conn.close

end


