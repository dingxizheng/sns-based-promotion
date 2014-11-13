# require 'net/http'
# require 'uri'
# require 'json'
# require 'mime/types'

require 'net/http/post/multipart'
url = URI.parse("http://localhost:3000/users")
file = '/Users/mover/Documents/Media/background/orange_fall-wallpaper-2560x1600.jpg'

user = { user: {
                   name: 'Bob',
                   email: 'bob@example.com',
                   phone: '1234566788',
                   logo: UploadIO.new(File.new(file), "image/jpeg", "image.jpg")
                      }
            }
# file = '/Users/mover/Documents/Media/background/orange_fall-wallpaper-2560x1600.jpg'

# puts user

# req = Net::HTTP::Post::Multipart.new url.path, user

# res = Net::HTTP.start(url.host, url.port) do |http|
#   http.request(req)
# end

Image.all

# puts res.body
