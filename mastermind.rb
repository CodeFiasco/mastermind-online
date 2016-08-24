require 'sinatra'

# Use cookies for session. Set expiration for 1 day
use Rack::Session::Pool, :expire_after => 86400

# Route GET
get '/' do
  if session[:code] == nil
    session[:code] = generate_code()
    session[:guesses] = []
    session[:results] = []
    session[:end?] = false
  end
puts "first"
  erb :index
end

post '/' do
  input = [params[:color_0].to_i, params[:color_1].to_i, params[:color_2].to_i, params[:color_3].to_i]
  result = check_secret_code(input, session[:code])

  session[:guesses] << input
  session[:results] << result

  if result.all? { |n| n == 2 } || session[:guesses].length == 10
    session[:end?] = true
  end

  erb :index
end

get '/new' do
  session[:code] = nil
  puts "here"
  redirect to('/')
end

private
# Method to create a random code
def generate_code
  secret_code = []
  4.times {secret_code << rand(6)}
  return secret_code
end

# Analyzes a given code and returns results
# 0 = wrong piece
# 1 = right piece, wrong place
# 2 = right piece, right place
def check_secret_code(input, code)
  correct_guess_right_place = 0
  correct_guess_wrong_place = 0

  aux_secret_code = Array.new(code)

  input.each_with_index do |x, idx|
    if x == aux_secret_code[idx]
      correct_guess_right_place += 1
      aux_secret_code[idx] = nil
    elsif aux_secret_code.include? (x)
      index_of_x = aux_secret_code.index(x)
      if aux_secret_code[index_of_x] != input[index_of_x]
        correct_guess_wrong_place += 1
        aux_secret_code[index_of_x] = nil
      end
    end
  end

  aux_results = []
  correct_guess_right_place.times { aux_results << 2 }
  correct_guess_wrong_place.times { aux_results << 1 }
  (4 - correct_guess_right_place - correct_guess_wrong_place).times { aux_results << 0 }

  return aux_results
end
