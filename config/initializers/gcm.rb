require 'gcm'

class GCM
	@@gcm = GCM.new('AIzaSyCMjwOIcFRsP01FUr7tt_LXkQ7VP9P46cI')

	def self.get
		@@gcm
	end
end