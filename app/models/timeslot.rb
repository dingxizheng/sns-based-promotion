class Timeslot
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user

  # when it starts
  field :start_at, type: DateTime
  # when it ends
  field :end_at, type: DateTime

  # in slot, can have many appointment
  has_and_belongs_to_many :appointments

  # every slot has to be unique
  validates_uniqueness_of :start_at, :end_at

  # slot has to be 30mins long 
  # validate :valid_time_format

  def valid_time_format
    start = Time.parse(self.start_at.hour.to_s + ':' + self.start_at.min.to_s + ':' + self.start_at.sec.to_s)
    time_passed = start - Time.parse('00:00')
    units = time_passed / 1800
    new_date = Date.new(self.start_at.year, self.start_at.month, self.start_at.day) + start.seconds_since_midnight

    puts self.start_at, start, time_passed, units, new_date

    errors.add(:start_at, 'start time must be in mins') unless self.start_at.to_i == new_date.to_i
    errors.add(:start_at, 'timeslot must be in 30mins increments') unless units.to_int == units and self.end_at.seconds_since_midnight - self.start_at.seconds_since_midnight  == 1800
  end

  # get aviable slot
  def self.aviliable_slot(start_at, end_at, user)
    slot = user.timeslots.and(:start_at => start_at, :end_at => end_at).first
    slot ||= Timeslot.create({ :start_at => start_at, :end_at => end_at, :user_id => user.get_id })
  end

  # return time slot which has time in between
  def self.aviliable_slot(time, user)
    slot = user.timeslots.and(:start_at.lte => time, :end_at.gte => time).first
    if slot.nil?
      units = time.seconds_since_midnight / 1800
      start_at = Date.new(time.year, time.month, time.day) + (units.floor * 1800).second
      slot = Timeslot.create({ :start_at => start_at, :end_at => start_at + 1799.second, :user_id => user.get_id })
    else
      slot
    end
  end

end