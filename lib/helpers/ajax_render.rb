class AjaxLinkRenderer < ::WillPaginate::ViewHelpers::LinkRenderer
  def page_number(page)
    unless page == current_page
      @template.link_to page, url(page), :rel => rel_value(page), :remote => true, :update => @options[:update]
    else
      tag(:em, page)
    end
  end
end