module Mongoid
  module QueryHelper
    extend ActiveSupport::Concern

    included do

      scope :sortby, ->(sortBy) {
        if sortBy.present? 
          # multiple sortBy parameters must be seperated by ',,'
          # for instance: 'sortBy=time,,name' ==> means sortBy 'time' and 'name'
          order_by_params = sortBy.split(',,').map do |item|    
            logger.tagged('SORTBY') { logger.info item }  
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
          logger.tagged('PAGE') { logger.info "page: #{page} , number per page: #{per_page}" }
          page(page).per(per_page)
        end
      }

      scope :query_by_params, ->(query_parameters) {
        query = {}
        query_parameters.each do |key, value|
          field = key.to_sym
          logger.tagged('QUERY') { logger.info "key: #{key} , value: #{value}"}

          if value.nil?
            logger.tagged('QUERY') { logger.info "query value is empty!"}
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

end
