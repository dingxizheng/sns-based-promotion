
module Mongoid::Document
  def get_id
    self.id.to_s
  end
end

module Mongoid
  # geo helper module
  module GeoHelper
    extend ActiveSupport::Concern
    
    included do
      # after_save :reindex_coordinates
      scope :with_in_radius, ->(location, radius) {
        if location and location[:lat] and location[:long] and radius
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

  # query module
  module QueryHelper
    extend ActiveSupport::Concern
    included do
      scope :sortby, ->(sortBy) {
        if sortBy.present? 
          # multiple sortBy parameters must be seperated by ',,'
          # for instance: 'sortBy=time,,name' ==> means sortBy 'time' and 'name'
          order_by_params = sortBy.split(',,').map do |item|      
            if item.start_with? '-'
              [item[1..-1].to_sym, -1]
            else
              [item.to_sym, 1]
            end
          end
          order_by(order_by_params)
        end
      }

      scope :paginate, ->(page, per_page) {
        # if pagenation is required, then return required page
        if page.present? and per_page.present?
          page(page).per(per_page)
        end
      }

      scope :query_by_params, ->(query_parameters) {
        query = {}
        query_parameters.each do |key, value|
          field = key.to_sym

          if value.nil?
            # do nothing
          elsif value.start_with? '<='
            query.store(field.lte, value[2..-1])
          elsif value.start_with? '<'
            query.store(field.lt, value[1..-1])
          elsif value.start_with? '>='
            query.store(field.gte, value[2..-1])
          elsif value.start_with? '>'
            query.store(field.gt, value[1..-1])
          elsif value.start_with? '!='
            if value == "!=null"
              query.store(field.exists, false)
            else
              query.store(field.nin, value[2..-1].split(',,'))
            end
          else
            if value == "null"
              query.store(field.exists, true)
            else
              query.store(field.in, value.split(',,'))
            end
          end
        end
        where(query)
      }
    end
  end

  # encryptable module
  module Encryptable
    extend ActiveSupport::Concern

    PRIFIX = 'ENCRYPTEDPRIFIX'

    # class methods
    # 
    # @params [Array] contains a list of fields
    module ClassMethods
      # Set fields that should be encrypted
      def encryptable(*fields)
        # puts "fields #{fields}"
        fields = fields.is_a?(Enumerable) ? fields : [fields]
        fields.each do |field_name|
          define_setter_and_getter(field_name)
        end
      end

      def define_setter_and_getter(field_name)
        # if field does not exists
        if self.fields[field_name.to_s].nil?
          # puts "field: #{field_name} does not exists!"
        elsif self.fields[field_name.to_s].options[:type] == String
          # puts "redefine setter and getter for field #{field_name}"
          
          define_method("#{field_name}=") do |value|
            if not value.nil? and value[0..(PRIFIX.size - 1)] == PRIFIX
              self[field_name] = value
            elsif not value.nil? and value[0..(PRIFIX.size - 1)] != PRIFIX
              self[field_name] = PRIFIX + Crypt.encrypt(value)
            end
          end

          define_method("#{field_name}") do  
            value = self[field_name]
            if not value.nil? and value[0..(PRIFIX.size - 1)] == PRIFIX
              return Crypt.decrypt(value[PRIFIX.size..-1])
            else
              return self[field_name]
            end
          end

          define_method("#{field_name}_encrypted") do
              return self[field_name]
          end

        else
          puts "field: #{field_name} is not String!"
        end
      end
    end
  end

end