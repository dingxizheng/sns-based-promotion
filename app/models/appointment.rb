class Appointment
	include Mongoid::Document
	include Mongoid::Timestamps

	before_save :check_timeslots

	# description of this appointment
	field :text, type: String
	field :start_at, type: DateTime
	field :end_at, type: DateTime

	belongs_to :booker, class_name: 'User', inverse_of: :booked_appointments
	belongs_to :accepter, class_name: 'User', inverse_of: :accepted_appointments
	has_and_belongs_to_many :timeslots

	# check timeslots
	def check_timeslots
		up_slot = Timeslot.aviliable_slot(self.start_at, self.accepter)
		down_slot = Timeslot.aviliable_slot(self.end_at, self.accepter)

		self.timeslots << up_slot
		self.timeslots << down_slot

		slots = (up_slot.start_at.seconds_since_midnight - down_slot.end_at.seconds_since_midnight - 1) / 1800

		for i in 0..slots
			put "indies...", slots
			slot = Timeslot.aviliable_slot(1800 * i + down_slot.end_at + 1.second, 1800 * i + down_slot.end_at + 1800.second, self.accepter)
			self.timeslots << slot
		end

	end

	# def aviable_slots()

end
