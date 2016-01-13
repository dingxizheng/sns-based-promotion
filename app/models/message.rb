class Message
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::QueryHelper

  after_create :send_msg

  # message type
  field :msg_type, type: String
  field :msg_body, type: Hash
  field :msg_send, type: Boolean, default: false
  field :msg_read, type: Boolean, default: false

  # relationships
  belongs_to :sender, inverse_of: :out_going_msgs, class_name: 'User'
  belongs_to :receiver, inverse_of: :in_coming_msgs, class_name: 'User'

  # send msg itself
  def send_msg
    if self.receiver.sessions.count > 0
      self.receiver.sessions.where({ :expire_at.gt => Time.now }).each{|session|
        if not session.device.nil?
          puts session.device.token
          if session.device.os == 'ios'
            self.to_ios(session.device)
          else 
            self.to_android(session.device)
          end
          self.msg_send = true
          self.save
        end
      }
    end
  end

  def to_ios(device)
    notification = Houston::Notification.new(device: device.token)
    notification.alert = self.msg_body[:message]
    notification.sound = "sosumi.aiff"
    notification.content_available = true
    notification.custom_data = self.msg_body
    res = APNS.get.push(notification)
    puts res
  end

  def to_android(device)
    res = GCM.get.send([device.token], {
      data: self.msg_body
    })
    puts res
  end

end
