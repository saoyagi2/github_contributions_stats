require 'sinatra'
require 'sinatra/reloader'
 
get '/' do
  @account = params[:account]
  erb :index
end
