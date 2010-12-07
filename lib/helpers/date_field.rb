module ActionView
  module Helpers
    module FormHelper
      def date_field(object_name, method, options = {})
        obj = ::ActionView::Helpers::InstanceTag.new(object_name, method, self).object
        text_field(object_name, method, options.merge(:value => ((v=obj.try(method)).blank? ? options[:value] : v.try(:to_s,:date)))) +
          date_picker("#{object_name}_#{method}")
      end

      def date_field_tag(name, value =nil, options= {})
        text_field_tag(name, value, options) +
          date_picker(name)
      end

      private
      def date_picker(dom_id)
        jquery_include_tag(:ui, :css, :i18n) +
          javascript_tag do
          "$(function() {
              $('##{dom_id}').datepicker({dateFormat: 'yy-mm-dd', changeYear: true, changeMonth: true});
              $('##{dom_id}').datepicker('option', $.datepicker.regional['#{I18n.locale}']);
           });"
        end
      end
    end

    class FormBuilder #:nodoc:
      def date_field(method, options = {})
        @template.date_field(@object_name, method, objectify_options(options))
      end
    end
  end
end