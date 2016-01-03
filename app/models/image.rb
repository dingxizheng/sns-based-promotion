class Image
  include Mongoid::Document
  include Mongoid::Timestamps

  # fields
  field :category, type: String
  field :file_name, type: String
  field :extension, type: String
  field :size, type: BigDecimal
  field :height, type: BigDecimal
  field :width, type: BigDecimal
  field :image_url, type: String
  field :thumb_url, type: String
  field :medium_url, type: String
  field :original_data, type: String

  # relations
  belongs_to :logo_owner, inverse_of: :logo, class_name: 'User'
  belongs_to :background_owner, inverse_of: :background, class_name: 'User'
  belongs_to :photos_owner, inverse_of: :photos, class_name: 'User'
  belongs_to :catagory
  belongs_to :promotion

  # save data from request 
  # in our case we don't store any images on local
  # all images uploaded will be forwarded to ultraimg.com
  def store(data_from_request = nil, filecontent = nil)
    
    unless data_from_request.nil? 
      puts data_from_request.original_filename
      file_name = data_from_request.original_filename  if  (data_from_request != '')    
      file = data_from_request.read
      self.file_name = file_name
    end

    unless filecontent.nil?
      # require 'fastimage'
      # size = FastImage.size(filecontent.path)
      # puts size
      file = filecontent
    end


    
    # require 'base64'
    # str = Base64.encode64(file)

    # require 'net/http'
    # uri = URI('http://ultraimg.com/api/1/upload/?key=3374fa58c672fcaad8dab979f7687397')
    # res = Net::HTTP.post_form(uri, 'source' => str)
    
    # puts 'file upload response:'

    # if res.code.eql? 200
    #   self.errors.add :file_name, file_name + ' could not be processed.'
    #   return false
    # end
    
    # require 'json'
    # data = JSON.parse(res.body)    
    # self.extension     = data["image"]["extension"]
    # self.size          = data["image"]["size"]
    # self.width         = data["image"]["width"]
    # self.height        = data["image"]["height"]
    # self.image_url     = data["image"]["image"]["url"]
    # self.thumb_url     = data["image"]["thumb"]["url"]
    # self.medium_url    = data["image"]["medium"]["url"] if data["image"]["medium"].present?
    # self.original_data = res.body
    # return true
    

    # use imgur *********
    response = Imgur.upload(file, self.file_name)

    if response['status'] != 200
        self.errors.add :file_name, self.file_name + ' could not be processed.'
        return false
    end

    self.extension     = response['data']['type']
    self.size          = response['data']['size']
    self.width         = response['data']['width']
    self.height        = response['data']['height']
    self.image_url     = response['data']['link']
    self.thumb_url     = response['data']['link'].sub(response['data']['id'], response['data']['id'] + 'b')
    self.medium_url    = response['data']['link']
    self.original_data = response
    return true

  end

end
