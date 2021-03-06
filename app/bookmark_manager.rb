require 'sinatra/base'
require 'sinatra/flash'
require_relative '../data_mapper_setup'

class BookmarkManager < Sinatra::Base
  use Rack::MethodOverride # This allows us to use a 'delete' method in our
  # server file --> browsers won't allow delete requests otherwise
  enable :sessions
  register Sinatra::Flash
  set :session_secret, 'super secret'

  helpers do
    def current_user
      @current_user ||= User.get(session[:user_id]) if session[:user_id]
    end
  end

  get '/' do
    erb :welcome
  end

  get '/users/new' do
    # creating new instance of User with no arguments means @user.email == nil
    # so the email field will be empty the first time we come across it
    # however, if we didn't have it here, the attempt to call @user.email
    # in the erb file would kick off a ruby NameError...
    @user = User.new
    erb :'users/new'
  end

  post '/users' do
    # use .new to avoid saving if the passwords don't match
    @user = User.new(email: params[:email],
                     password: params[:password],
                     password_confirmation: params[:password_confirmation])
    if @user.save
      session[:user_id] = @user.id
      redirect('/links')
    else
      flash.now[:errors] = @user.errors.full_messages
      # having established that @user couldn't save, we know it failed the
      # validation process & must therefore have received non-matching passwords
      # We therefore go back to erb :'/users/new', but this time @user will
      # retain the @user.email value that was set at the top of this route,
      # so that this information is not lost when the page refreshes
      erb :'users/new'
    end
  end

  get '/users/password_reset' do
    erb :'users/password_reset'
  end

  post '/users/password_reset' do
    reset_email = params[:email]
    User.reset_password(reset_email)
    flash.now[:notice] = 'Thank you. Please check your emails for a reset link.'
    erb :'users/password_reset'
  end

  get '/sessions/new' do
    erb :'sessions/new'
  end

  post '/sessions' do
    user = User.authenticate(params[:email], params[:password])
    if user
      session[:user_id] = user.id
      redirect to('/links')
    else
      flash.now[:errors] = ['The email and/or password you provided are incorrect']
      erb :'/sessions/new'
    end
  end

  delete '/sessions' do
    session[:user_id] = nil
    flash.now[:notice] = 'You are now signed out. Have a nice day!'
    erb :welcome
  end

  get '/links' do
    @links = Link.all
    erb :'links/index'
  end

  get '/links/new' do
    erb :'links/new'
  end

  post '/links' do
    link = Link.new(url: params[:url], title: params[:title])
    params[:tag].empty? ? tag_array = ['Untagged'] : tag_array = params[:tag].split(', ')
    tag_array.each do |tag|
      new_tag = Tag.create(name: tag.capitalize)
      link.tags << new_tag
    end
    link.save
    redirect('/links')
  end

  get '/tags/:name' do
    tag = Tag.all(name: params[:name])
    @links = (tag ? tag.links : [])
    erb :'links/index'
  end

  # start the server if ruby file executed directly
  run! if app_file == $PROGRAM_NAME
end
