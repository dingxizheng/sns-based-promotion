require 'net/http'
require 'net/https'
require 'open-uri'
require 'json'
require 'base64'

API_URI = URI.parse('https://api.imgur.com')
API_PUBLIC_KEY = 'Client-ID 72d133807ce2a99'
 
ENDPOINTS = {
    :image => '3/image',
    :upload => '/3/upload'
}

class Imgur

	def self.web_client
	  http = Net::HTTP.new(API_URI.host, API_URI.port)
	  http.use_ssl = true
	  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
	  http
	end

	def self.upload(img, name = 'image') 
		# img = File.open(imagepath, "rb") {|io| io.read}
		params = {:image =>  Base64.encode64(img),
		          :gallery => "gallery",
		          :name => name
		}
		 
		request = Net::HTTP::Post.new(API_URI.request_uri + ENDPOINTS[:image])
		request.set_form_data(params)
		request.add_field('Authorization', API_PUBLIC_KEY)
		 
		response = web_client.request(request)
		return JSON.parse(response.body)
	end

end