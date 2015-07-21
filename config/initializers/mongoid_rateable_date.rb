# module Mongoid
#   module Rateable
#     extend ActiveSupport::Concern

#     def last_rated_at(rater)
#     	r = self.rating_marks.where(:rater_id => rater.id, :rater_class => rater.class.to_s).desc(:created_at).first
#     	r ? r.created_at : nil
#     end

#   end
# end
