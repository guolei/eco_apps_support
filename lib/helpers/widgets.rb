# encoding: utf-8

module EcoAppsSupport
  module Helpers

    def info_table_for(data, options = {})
      content_tag :table, :class=>["info-table", options[:css]].compact.join(" ") do
        data.map{|row|
          content_tag(:tr){
            c = ""
            row.each do |cell|
              options = cell.extract_options!
              c << content_tag(:th, cell.shift) if cell.size > 1
              c << cell.map{|t| content_tag(:td, t, options)}.join
            end
            c.html_safe
          } 
        }.join.html_safe
      end.html_safe
    end

    def list_table_for(collection = [], options = {}, &block)
      tid = "table_#{rand(1000)}"

      html = collection.blank? ? "".html_safe :
        content_tag(:table, {:id => tid, :class => ["list_table", options[:class]].compact.join(" ")}) do
        content = "".html_safe
        collection.each_with_index do |item, index|
          row = block.call(item, ListTableColumn.new(index))

          if row.first?
            if options[:searchable]
              content << ""
            end

            unless options[:ignore_header]
              content << content_tag(:thead) do
                content_tag :tr do
                  row.head.map{|i| build_table_head(i)}.join.html_safe
                end
              end
            end

            content << "<tbody>".html_safe
          end

          tr_options = {:class => [cycle("even", nil), row.css].compact.join(" ")}
          tr_options[:id] = item.dom_id(options[:item_prefix]) if item.respond_to?(:dom_id)
          tr_options[:style] = "background: #{row.tr_color}" if row.tr_color.present?

          content << content_tag(:tr, tr_options) do
            row.content.map{|i| content_tag(:td, i.is_a?(Symbol) ? item.try(i) : i.html_safe)}.join.html_safe
          end
        end
        content << "</tbody>".html_safe
      end

      if collection.respond_to?(:total_entries)
        ignore = options[:ignore_footer] || (collection.total_entries >0 and collection.total_entries <= 5)
        unless ignore
          html << paginate_links(collection, options[:update], options[:paginate_params])
        end
      end

      html << make_table_sortable(tid) if options[:sortable]
      html
    end

    def paginate_links(collection, update = nil, custom_params = {})
      content_tag :div, :class => "list_table_page" do
        if collection.is_a?(WillPaginate::Collection)
          content = t(:total_record, :count => collection.total_entries).html_safe
          content << collection_range_title(collection).to_s
          if collection.total_entries > 0
            if collection.total_pages > 5 and update.blank?
              content << t(:jump_to)
              content << form_tag(request.url, :method=>:get) do
                text_field_tag(:page, params[:page], :size=>3)
              end
            end
            content << (will_paginate(collection, {:previous_label=>t(:previous_page), :next_label=>t(:next_page), :params => custom_params}.merge(update.blank? ? {} : {:renderer => '::AjaxLinkRenderer', :update=>update})) || "")
          end
          content
        else
          t(:total_record, :count => collection.size)
        end
      end
    end

    def make_table_sortable(table_id)
      javascript_tag do
        %{var sorter = new TINY.table.sorter("sorter");
          sorter.head = "head";
          sorter.asc = "desc";
          sorter.desc = "asc";
          sorter.even = "even";
          sorter.odd = "";
          sorter.evensel = "evenselected";
          sorter.oddsel = "oddselected";
          sorter.paginate = true;
          sorter.currentid = "";
          sorter.limitid = "pagelimit";
          sorter.init("#{table_id}",1);}
      end
    end

    def calendar_view(options = {}, &block)
      now = params[:month] || options[:month] || Time.now
      now =  ((now.is_a?(String) and now =~ /\d+-\d+/) ? now + "-01" : now).to_time.in_time_zone

      bom = now.beginning_of_month
      eom = now.end_of_month

      if (eom.day == 31 and bom.wday >= 5) or (eom.day == 30 and bom.wday == 6)
        rows = 6
      else
        rows = 5
      end

      content_tag(:table, :class => "calendar_view") do
        html = "".html_safe
        html = content_tag(:tr) do
          content_tag(:th, :class => "hl"){month_link(now, -1)} +
            content_tag(:th, :class => "hl", :colspan => 5){month_link(now)} +
            content_tag(:th, :class => "hl"){month_link(now, 1)}
        end unless options[:ignore_header]

        html << content_tag(:tr) do
          %w{sunday monday tuesday wednesday thursday friday saturday}.map{|d| content_tag(:th, t(d))}.join.html_safe
        end

        loop_time = bom - bom.wday.days

        rows.times do
          date = content_tag(:tr, :class => "date") do
            (0..6).map{|i|
              css = calendar_day_style(loop_time + i.day, now)
              content_tag(:td, (loop_time + i.day).day, css.blank? ? {} : {:class => css})
            }.join.html_safe
          end

          content = content_tag(:tr, :class => "content") do
            (0..6).map{|i|
              css = calendar_day_style(loop_time + i.day, now)
              content_tag(:td, block.call(loop_time + i.day), css.blank? ? {} : {:class => css})
            }.join.html_safe
          end

          html << date << content
          loop_time += 7.days
        end

        html
      end 
    end

    private

    class ListTableColumn
      attr_reader :index
      attr_accessor :head, :content, :index, :tr_color, :css
      def initialize(_index)
        @head, @content, @index = [], [], _index
      end

      def add(*args)
        header = args.shift

        @head << [header, args.extract_options!]
        @content << (args.size > 0 ? args.join("") : header)
        self
      end

      def build(*attrs)
        attrs.each{|t| self.add(t)}
        self
      end

      def first?
        @index == 0
      end
    end

    def build_table_head(head_array)
      value, options = head_array
      value = t(value) if value.class==Symbol
      td_class = nil

      unless (order = options[:sort] || options[:order]).blank?
        query = {}
        query[:sc] = (params[:sc].blank? or params[:sc] == "desc") ? "asc" : "desc"
        query[:order] = order

        value = link_to(value, URI.parse(request.url).add_query(query).to_s)
        
        td_class = options[:sc] if options[:order].to_s == params[:order].to_s
      end
      
      args = {}
      args[:class] = td_class unless td_class.blank?
      args[:style] = "width: #{options[:width]}" unless options[:width].blank?
      content_tag :th, value.html_safe, args
    end

    def collection_range_title(collection)
      if collection.blank?
        page_begin, page_end = 0, 0
      else
        page_begin = collection.per_page * (collection.current_page - 1) + 1
        page_end = (collection.current_page == collection.total_pages) ? collection.total_entries : (page_begin + collection.per_page - 1)
      end
      unless collection.total_entries == 0
        "(#{page_begin}～#{page_end})"
      end
    end

    def month_link(now, addon = 0)
      m = (now + addon.month).to_s(:month)
      link_to m, URI.parse(request.url).add_query(:month => m).to_s
    end

    def calendar_day_style(loop_time, now)
      (loop_time.month == now.month ? (loop_time.to_date==Time.now.to_date ? "today" : nil) : "grey")
    end

  end
end
