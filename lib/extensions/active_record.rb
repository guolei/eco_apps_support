module EcoAppsSupport
  module Extensions
    module ActiveRecord

      def self.included(base)
        base.send(:include, ObjectMethods)
        base.send(:include, ClassAndObject)
        base.extend(ClassMethods)
        base.extend(ClassAndObject)
      end

      module ObjectMethods

        def dom_id(prefix = "")
          ([prefix, self.class.to_s.tableize.singularize, self.id.to_s] - ["",nil]).join("_")
        end

      end

      module ClassMethods
        def day_condition_for(day, column = "created_at")
          ["#{column} >= ? and #{column} < ?",
            day.to_time.in_time_zone.beginning_of_day,
            day.to_time.in_time_zone.end_of_day]
        end
      end

      module ClassAndObject

        def days_between(from, to, ignore_weekend = false)
          return 0 if from.blank? or to.blank?
          from = from.to_time.in_time_zone.beginning_of_day
          to = to.to_time.in_time_zone.beginning_of_day
          i = 0
          while from < to
            i += 1 unless ignore_weekend and [0, 6].include?(from.wday)
            from += 1.day
          end
          i
        end

        def convert_tz(column_name, format="%Y-%m-%d")
          format = case format
          when :month
            "%Y-%m"
          when :day
            "%Y-%m-%d"
          when :hour
            "%H:%M"
          else
            format
          end
          Time.zone = "UTC" if Time.zone.blank?
          "DATE_FORMAT(CONVERT_TZ(#{column_name}, '+00:00', '#{Time.zone.formatted_offset}'),'#{format}')"
        end

        def find_column_by_name(column_name)
          column_name = column_name.to_s
          if column_name =~ /(.*)\.(.*)/
            klass = $1.classify.constantize
            column_name = $2
          else
            klass = self
          end
          klass.columns.detect{|t| t.name == column_name}
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, EcoAppsSupport::Extensions::ActiveRecord)