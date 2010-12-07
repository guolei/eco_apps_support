module EcoAppsSupport
  module ComboSearch

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def search_key
        "q"
      end
      
      def combo_search(conditions, options = {}, &block)
        col = self
        [:order, :joins, :includes].each do |opt|
          col = col.send(opt, options.delete(opt))
        end

        conditions = build_sql_conditions(conditions, options[:conditions], &block)
        conditions = "1=2" if conditions.blank? and options[:default] == :none

        options[:paginate] == false ? col.where(conditions) :
          col.where(conditions).paginate(:page=> options[:page]||1, :per_page=>options[:per_page]||20)
      end

      def build_sql_conditions(conditions, addition = {}, &block)
        return nil if conditions.blank? and addition.blank?

        builder = []
        builder << build_sql_conditions(addition) unless addition.blank?

        if conditions.is_a?(String)
          builder << conditions
        else
          conditions.each do |key, value|
            if value.kind_of?(Hash)
              conditions.delete(key)
              type = find_column_by_name(key).type
              
              builder += EcoAppsSupport::ComboSearch::SqlHash.handle(key, value, type)
              builder << block.call(SqlHash).call(key, value, type) if block_given?
            end
          end
          builder << sanitize_sql_hash_for_conditions(conditions)
        end
        (builder - [nil, ""]).join(' AND ')
      end
      
    end

    class SqlHash
      class << self
        def subclasses
          @subclasses ||= []
        end

        def inherited(base)
          subclasses << base
        end

        def handle(column, hash_value, column_type)
          subclasses.map do |klass|
            klass.new.sql_for(column, hash_value, column_type)
          end
        end

        def match(hash_key, column_type = nil, &block)
          define_method :sql_for do |_column, _hash_value, _column_type|
            type_valid = (column_type.blank? ? true : [column_type].flatten.include?(_column_type))

            if _hash_value.stringify_keys.keys.include?(hash_key.to_s) and type_valid
              value = _hash_value.with_indifferent_access[hash_key]
            
              case block.arity
              when 1
                block.call(_column)
              when 2
                block.call(_column, value)
              when 3
                block.call(_column, value, _column_type)
              end
            end
          end
        end
      end
    end

    class NullCheckSqlHash < SqlHash
      match :is_null do |column, value|
        "#{column} #{value== true ? "is" : "is not"} null"
      end
    end

    class AmPmSqlHash < SqlHash
      match :ampm, [:datetime, :date] do |column, value|
        key = ActiveRecord::Base.convert_tz(column, "%H")
        (value == "am" ? "#{key} BETWEEN 0 AND 11" : "#{key} BETWEEN 12 AND 23")
      end
    end

    class FromSqlHash < SqlHash
      match :from do |column, value, column_type|
        return if value.blank?
        if [:datetime, :date].include?(column_type)
          "#{column} >= '#{value.to_time.in_time_zone.beginning_of_day.to_s(:db)}'"
        elsif column_type == :integer
          "#{column} >= #{value}"
        end
      end
    end

    class ToSqlHash < SqlHash
      match :to do |column, value, column_type|
        return if value.blank?
        if [:datetime, :date].include?(column_type)
          "#{column} <= '#{value.to_time.in_time_zone.end_of_day.to_s(:db)}'"
        elsif column_type == :integer
          "#{column} <= #{value}"
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, EcoAppsSupport::ComboSearch)