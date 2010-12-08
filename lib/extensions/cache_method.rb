module EcoAppsSupport
  module CacheMethod #:nodoc:
    def cache_method(method, *variables)
      alias_method "initial_#{method}", method
      define_method(method){|*args|
        if variables.size > 0
          # cache methods like new_actions_link(action_trigger)
          # cache_method(:new_actions_link, :id, :class_name)
          i_name = "@#{method}"
          if instance_variable_get(i_name).blank?
            obj = args.first.clone
            obj.class.cattr_accessor :variables
            obj.class.variables = variables
            class << obj
              self.variables.each{|var|
                define_method(var){
                  "__#{var}__"
                }
              }
            end
            instance_variable_set(i_name, send("initial_#{method}", obj))
          end

          final = instance_variable_get(i_name)
          variables.each{|var|
            final = final.gsub(/__#{var}__/m){|t| args.first.send(var)}
          }
          final
        else
          # cache methods like translate(:edit)
          i_name = "@#{method}"
          instance_variable_set(i_name, {}) if instance_variable_get(i_name).blank?
          var_name = args.join("_")
          instance_variable_get(i_name)[var_name] ||= send("initial_#{method}", *args)
        end
      }
    end
  end
end

