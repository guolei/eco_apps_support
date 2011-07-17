module EcoAppsSupport
  module Helpers
    
    def load_once(key, &block)
      key = "@#{key}" unless key.to_s =~ /@/
      return "" if instance_variable_get(key).present?
      content = block.call
      instance_variable_set(key, content)
    end

    def jquery_include_tag(*files)
      if files.size >= 2
        files.map{|file| jquery_include_tag(file)}.join.html_safe
      else
        klass = files.first

        cdn = case klass
        when :ui
          javascript_include_tag %{https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.6/jquery-ui.min.js}
        when :css
          stylesheet_link_tag %{https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.6/themes/base/jquery-ui.css}
        when :i18n
          javascript_include_tag %{https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.6/i18n/jquery-ui-i18n.min.js}
        else
          javascript_include_tag(%{https://ajax.googleapis.com/ajax/libs/jquery/1.6/jquery.min.js}) +
            javascript_include_tag("rails")
        end
        load_once("jquery_#{klass}"){cdn}
      end
    end

    def document_ready(content = nil ,&block)
      "$(document).ready(function(){#{block_given? ? block.call : content}});"
    end

    def toggle_element(dom_id)
      %{$('##{dom_id}').toggle('fast');}
    end

    def popup(*args, &block)
      js = load_once("jquery_colorbox") do
        javascript_include_tag("jquery.colorbox") + stylesheet_link_tag("colorbox")
      end
      
      options = args.extract_options!
      box_options = []
      box_options << "width:'#{options.delete(:width) || "60%"}'"
      if (height = options.delete(:height))
        box_options << "height:'#{height}'" 
      end
      box_options << "iframe:true" if options.delete(:iframe)
      box_options << "title:'#{options.delete(:title)||args.first}'"

      if args.size == 2 and args.last =~ /^#(.+)/
        box_options << "inline:true" << %{href:"##{$1}"}
        args[1] = "#"
      end

      klass = "box_#{rand(1000)}"
      options[:class] = [klass, options[:class]].compact.join(" ")
      js.html_safe + link_to(*(args << options), &block) +
        javascript_tag(document_ready{
          %{$(".#{klass}").colorbox({#{box_options.join(", ")}});}
        })
    end

    def ajax_load(url, options = {})
      dom_id = "ajax_#{rand(1000)}"
      content_tag(:div, :id => dom_id){content_tag :div, "", :class => "loading"} +
        javascript_tag{%{ajaxLoad("#{dom_id}", "#{url}")}}
    end
    
    def autocomplete(dom_id, url)
      jquery_include_tag(:ui, :css) +
      javascript_tag do
        document_ready do
          %{
              $('##{dom_id}').autocomplete({
                  source: '#{url}'
              });
          }
        end
      end
    end
  end
end