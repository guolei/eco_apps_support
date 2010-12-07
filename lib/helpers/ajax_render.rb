class AjaxLinkRenderer < ::WillPaginate::ViewHelpers::LinkRenderer
  def page_link_or_span(page, span_class = 'current', text = nil)
    text ||= page.to_s
    if page and page != current_page
      @template.link_to text, url_for(page), :remote => true, :update => @options[:update], :method => :get
    else
      @template.content_tag :span, text, :class => span_class
    end
  end
end