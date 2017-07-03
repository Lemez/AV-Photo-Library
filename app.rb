require "sinatra"
require 'json'
require_relative('./script')

set :server, %w[webrick mongrel thin]

get "/" do
  	erb :index
end

get '/fetch_images' do
	content_type :json
	data = get_data
	data.to_json
end


