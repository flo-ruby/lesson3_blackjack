require 'rubygems'
require 'sinatra'
require 'pry'

CARD_VALUES = ["ace", "2", "3", "4", "5", "6", "7", "8", "9", "10", "jack", "queen", "king"]
CARD_SUITS = [:clubs, :diamonds, :hearts, :spades]
INITIAL_MONEY = 500
IMAGE_PATH = "images/cards/"

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'DzDnUyYoEX' 

helpers do
  def create_shoe
    deck = CARD_VALUES.product(CARD_SUITS)
    shoe = deck.shuffle
  end

  def show_card(card)
    IMAGE_PATH + "#{card[1]}_#{card[0]}.jpg"
  end

  def cover_card
    IMAGE_PATH + "cover.jpg"
  end

  def card_value(card)
    case card[0]
    when "ace"
      return 11
    when "jack"
      return 10
    when "queen"
      return 10
    when "king"
      return 10
    else
      return card[0].to_i
    end
  end

  def number_of_aces(hand)
    hand.select do |card|
      card.include?("ace")
    end.count
  end

  def hand_value(hand)
    hand_values = hand.map do |card|
      card_value(card)
    end
    v = hand_values.reduce(:+)
    n = number_of_aces(hand)
    while (v > 21) && (n > 0)
      v = v - 10
      n = n - 1
    end
    return v
  end
end

get '/' do
  if session[:player_name]
    redirect '/make_bet'
  else
    redirect '/new_player'
  end
end

get '/new_player' do
  erb :set_name
end

post '/new_player' do
  if params[:player_name] == ""
    redirect '/'
  end
  session[:player_name] = params[:player_name]
  session[:player_money] = INITIAL_MONEY
  redirect '/make_bet'
end

get '/make_bet' do
  erb :make_bet
end

post '/make_bet' do
  if (params[:bet_amount].to_i == 0)
    redirect '/make_bet'
  elsif params[:bet_amount].to_i > session[:player_money]
    redirect '/make_bet'
  else
    session[:bet_amount] = params[:bet_amount].to_i
    redirect '/draw_cards'
  end
end

get '/draw_cards' do
  # set up initial games values
  create_shoe
  session[:shoe] = create_shoe
  session[:player_hand] = [session[:shoe].pop, session[:shoe].pop]
  session[:dealer_hand] = [session[:shoe].pop, session[:shoe].pop]
  redirect '/game'
end

get '/game' do
  # calculate player points
  @player_points = hand_value(session[:player_hand])

  if @player_points > 21
    @text_for_player_over_21 = "You have #{@player_points} points. That is more than 21! Dealer wins."
  elsif @player_points == 21
    @text_for_player_21 = "Wow, you got 21! You made the blackjack and you win!"
  end

  # render template
  erb :game
end

post '/player/hit' do
  session[:player_hand] << session[:shoe].pop
  redirect '/game'
end

post '/player/stay' do
  "Player turn is over"
end