module Mongoid
  module GeoHelper
    extend ActiveSupport::Concern

    included do

      after_save :reindex_coordinates

      scope :with_in_radius, ->(location, radius) {
        if location and radius
          near([location[:lat], location[:long]], Float(radius), :units => :km)
        end
      }
    end

    # reindex coordinates after save
    def reindex_coordinates
      if self.coordinates_changed?
        Thread.start{
          require 'rake'
          Rake::Task.clear
          Rails.application.load_tasks
          Rake::Task['db:mongoid:create_indexes'].invoke
        }
      end
    end

  end

end
