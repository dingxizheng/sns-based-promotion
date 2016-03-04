
module Mongoid::Document
  def get_id
    self.id.to_s
  end
end

module Mongoid

  # count relations
  module RelationCounter
    extend ActiveSupport::Concern

    module ClassMethods
      def count_relations(*relations)
        
        relations = relations.is_a?(Enumerable) ? relations : [relations]
        relations.each do |relation_name|  
          # puts "field #{relation_name}_count, type: Integer, :default: 0"
          field "#{relation_name}_count".to_sym, type: Integer, default: 0      
          before_save :update_relation_counts
        end

        define_method(:update_relation_counts) do
          relations.each do |relation_name|
            self["#{relation_name}_count".to_sym] = self.send("#{relation_name}").count
          end
        end

      end
    end

  end

  # geo helper module
  module GeoHelper
    extend ActiveSupport::Concern
    
    included do
      before_save :convert_coordinates
      # before_save :reindex_coordinates
      scope :with_in_radius, ->(location, radius) {
        if location and location[:lat] and location[:long] and radius
          puts "$NEAR >> #{ radius.to_f * 1000 }"
          # near([location[:lat], location[:long]], Float(radius), :units => :km)
          where({
              :coordinates => {
                '$near' => {
                  '$geometry' => { 
                    type: "Point", 
                    coordinates: [location[:long].to_f, location[:lat].to_f]
                  },
                  '$minDistance' => 0,
                  '$maxDistance' => radius.to_f * 1000
                }
                # '$minDistance' => 0,
                # '$maxDistance' => radius.to_f * 1000
              }
            })
        end
      }

      # index coordinates
      index({ coordinates: "2dsphere" })
    end

    def convert_coordinates
      if self.coordinates_changed?
        self.coordinates = [self.coordinates[0].to_f, self.coordinates[1].to_f]
      end
      true
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
          # multiple sortBy parameters must be seperated by '&&'
          # for instance: 'sortBy=time&&name' ==> means sortBy 'time' and 'name'
          order_by_params = sortBy.split('&&').map do |item|      
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

      scope :query_by_text, -> (text) {
        if text.present? and text.kind_of? String
          full_text_search(text) if respond_to? "full_text_search"
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
              query.store(field.exists, true)
            else
              query.store(field.nin, value[2..-1].split('&&'))
            end
          else
            if value == "null"
              query.store(field.exists, false)
            else
              if value.split('&&').size < 1
                query.store(field.in, value.split('||'))
              else
                # puts "QUERY >>> AND"
                value.split('&&').each{|val|  query.store(field.in, val.split('||')) }
              end
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