#!/usr/bin/ruby
# @Author: dingxizheng
# @Date:   2016-01-12 01:33:32
# @Last Modified by:   dingxizheng
# @Last Modified time: 2016-01-12 01:38:36

class Crypt
	@@crypt = ActiveSupport::MessageEncryptor.new(Settings.secret_key_base)

	def self.encrypt(data)
		@@crypt.encrypt_and_sign(data)
	end

	def self.decrypt(data)
		@@crypt.decrypt_and_verify(data)
	end
end