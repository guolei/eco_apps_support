module EcoAppsSupport
  module Helpers

    def search_form_for(klass, *attrs)
      options = attrs.extract_options!
      url = options[:url] || url_for(:controller => params[:controller], :action => params[:action])

      hidden = [options[:hidden]].flatten.compact.map{|key|
        key.is_a?(Hash) ? key.map{|k, v| hidden_field_tag(k, v)}.join :
          (params[key].blank? ? "" : hidden_field_tag(key, params[key]))
      }.join.html_safe
        
      simple = options[:simple]||1

      content_tag :span, {:class => "combo_search"} do
        c = ""

        toggle = toggle_element("advanced_search")
        c << link_to_function(t(:advanced), toggle) if attrs.size > simple

        c << content_tag(:span, :id => "simple_search") do
          form_tag(url, :method => :get, :onsubmit=>"filterNullValue('simple_search')") do
            hidden +
              (1..simple).to_a.map{|t| search_content_for(klass, attrs[t-1], false)}.join.html_safe +
              submit_tag(t(:search))
          end
        end

        if attrs.size > simple
          c << content_tag(:div, :id => "advanced_search", :style=> "display:none") do
            form_tag(url, :method => :get, :onsubmit => "filterNullValue('advanced_search')") do
              hidden +
                content_tag(:table) do
                attrs.map{|attr| search_content_for(klass, attr)}.join.html_safe +
                  table_line_tag("", submit_tag(t(:search)) + link_to_function(t(:cancel), toggle))
              end
            end
          end
        end
        c
      end
    end

    def search_tag(url, search_tip = "", options = {})
      dom_id = "search_form_#{rand(1000)}"
      options[:onsubmit] = "filterNullValue('#{dom_id}')" unless options[:remote]
      
      form_tag(url, {:method => :get, :id => dom_id}.merge!(options)) do
        search_field_tag(:q, search_tip, options) +
          submit_tag(t(:search))
      end
    end

    private

    def search_content_for(klass, attr, advance = true)
      column = (attr.is_a?(Array) ? attr.first : attr)
      key = "#{klass.search_key}[#{column}]"
      value = params[klass.search_key].try("[]", column)

      content = attr.is_a?(Array) ? search_content_for_array(klass, attr, key, value) :
        search_content_for_column(klass, attr, key, value)
      title = translate(column =~ /(.*)\.(.*)/ ? $2 : column)

      (advance ? table_line_tag(title, content) : title + content).html_safe
    end

    def table_line_tag(title, content)
      content_tag :tr do
        content_tag(:td, :class => "title" ){title} +
          content_tag(:td){content}
      end
    end
    
    def search_content_for_column(klass, column, key, value)
      column_type = klass.find_column_by_name(column).type
      case column_type
      when :datetime, :date
        date_field_tag("#{key}[from]", value.try("[]","from"), :size => 20) +
          " - "+ date_field_tag("#{key}[to]", value.try("[]","to"), :size => 20)
      when :boolean
        select_tag(key, options_for_select([nil, true, false], value))
      else
        text_field_tag(key, value)
      end
    end

    def search_content_for_array(klass, array, key, value)
      options = array.extract_options!
      column = array.first

      case options.keys.first
      when :collection
        value = value.to_i if value =~ /^[0-9]+$/
        select_tag(key, options_for_select([nil] + options[:collection], value))
      when :range
        text_field_tag("#{key}[from]", value.try("[]","from"), :size => 5) +
          " - " + text_field_tag("#{key}[to]", value.try("[]","to"), :size => 5)
      when :null_check
        list = [[t(:list_label),nil], [t(:is_null), true], [t(:is_not_null), false]]
        t(:null_check) + select_tag("#{key}[is_null]", options_for_select(list, value.try("[]", "is_null")))
      when :ampm
        list = [nil, [t(:am), "am"], [t(:pm), "pm"]]
        search_content_for_column(klass, column, key, value) + select_tag("#{key}[ampm]", options_for_select(list, value.try("[]","ampm")))
      end
    end

    def search_field_tag(name, default_text = "", options={})
      js = %{if(value=='#{default_text}'){value='';style.color='#000';}}
      text_field_tag name, (params[name]||default_text),{:style=>"color:#{params[name].blank? ? '#666' : '#000'}", :onclick=>js, :size=>(options[:size]||30)}
    end
  end
end

