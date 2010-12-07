module EcoAppsSupport
  module Helpers

    def jquery_include_tag(*files)
      if files.size >= 2
        files.map{|file| jquery_include_tag(file)}.join.html_safe
      else
        klass = files.first
        variable = "@jquery_#{klass}"
        return "" if instance_variable_get(variable).present?

        cdn = case klass
        when :ui
          javascript_include_tag %{https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.6/jquery-ui.min.js}
        when :css
          stylesheet_link_tag %{https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.6/themes/base/jquery-ui.css}
        when :i18n
          javascript_include_tag %{https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.6/i18n/jquery-ui-i18n.min.js}
        else
          javascript_include_tag %{https://ajax.googleapis.com/ajax/libs/jquery/1.4.4/jquery.min.js}
        end
        instance_variable_set(variable, cdn)
      end
    end

    def document_ready(content = nil ,&block)
      "$(document).ready(function(){#{block_given? ? block.call : content}});"
    end

    def toggle_element(dom_id)
      %{$('##{dom_id}').toggle('slow');}
    end

    def popup(*args, &block)
      options = args.extract_options!
      box_options = []
      [:width, :height].each do |attr|
        v = options.delete(attr) || "60%"
        box_options << attr.to_s + ":" + (v.is_a?(String) ? %{"#{v}"} : v.to_s)
      end
      box_options << "iframe:true" if options.delete(:iframe)

      klass = "box_#{rand(1000)}"
      options[:class] = klass
      link_to(*(args << options), &block) +
        javascript_tag(document_ready{
          %{$(".#{klass}").colorbox({#{box_options.join(", ")}});}
        })
    end

    def ajax_load(url, options = {})
      dom_id = "ajax_#{rand(1000)}"
      content_tag(:div, :id => dom_id){content_tag :div, "", :class => "loading"} +
        javascript_tag{%{ajaxLoad("#{dom_id}", "#{url}")}}
    end
  end
end