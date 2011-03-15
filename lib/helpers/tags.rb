module EcoAppsSupport
  module Helpers

    def active_link_to(label, url, active = nil, options = {})
      active = (url =~/#{request.path}$/) if active.nil? and request.path.present?
      added = (active ? {:class => "active"} : {})
      if options.delete(:with_li) == false
        link_to(label, url, options.merge(added))
      else
        content_tag(:li, added){link_to(label, url, options)}           
      end
    end
  end
end