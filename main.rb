require 'rubygems'
require 'sinatra'
require 'pry'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'DzDnUyYoEX' 

helpers do
  def calculate_total(cards)
    55
  end
end

get '/' do
  erb :set_name
end

post '/set_name' do
  session[:player_name] = params[:player_name]
  redirect '/game'
end

get '/game' do
  session[:deck] = [['2', 'H'], ['3', 'D']]
  session[:player_cards] = []
  session[:player_cards] << session[:deck].pop
  erb :game
end