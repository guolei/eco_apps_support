require 'initializer'

require 'extensions/active_record'
require 'extensions/fixnum'
require 'extensions/string'
require 'extensions/cache_method'
require 'extensions/i18n'

require 'models/combo_search'

require 'helpers/search_form'
require 'helpers/date_field'
require 'helpers/js_effect'
require 'helpers/widgets'
require 'helpers/tags'

ActionView::Base.send(:include, EcoAppsSupport::Helpers)