# encoding: utf-8

module EcoAppsSupport
  module Helpers
    module TranslationHelper
      include ActionView::Helpers::TranslationHelper
      extend EcoAppsSupport::CacheMethod

      alias_method :rails_t, :translate
      def translate(key, options = {})
        if self.kind_of?(ActionView::Base) or self.kind_of?(ActionController::Base)
          chain = (params[:controller].to_s.split("/") + [params[:action]]).compact
          while chain.size > 0
            c = trans((chain + [key]).join("."), options)
            return c unless c.blank?
            chain.pop
          end

          begin
            I18n.translate(key, options.merge!(:raise => true))
          rescue I18n::MissingTranslationData => e
            c = trans("common.#{key}", options)
            return c unless c.blank?
            return key.to_s.titleize if I18n.locale.to_s == "en"
            rails_t(key, options)
          end
        end
      end
      alias :t :translate
      cache_method :t

      private
      def trans(key, options)
        begin
          I18n.translate(key, options.merge!(:raise => true))
        rescue I18n::MissingTranslationData => e
          nil
        end
      end
    end
  end

  module TimeConversions
    def self.included(base) #:nodoc:
      base.class_eval do
        alias_method :to_s, :to_idp_s
      end
    end

    def to_idp_s(format = :default)
      begin
        formatter = I18n.t("time.formats.#{format}", :raise => true) 
        return strftime(formatter).gsub(/0(\d+[月日])/){|t| $1}
      rescue I18n::MissingTranslationData => e
        return to_formatted_s(format)
      end
    end
  end
end

[Time, ActiveSupport::TimeWithZone, Date].each do |klass|
  klass.send(:include, EcoAppsSupport::TimeConversions)
end

[ActionController::Base, ActiveRecord::Base, ActionView::Base].each do |klass|
  klass.send(:include, EcoAppsSupport::Helpers::TranslationHelper)
end

I18n.load_path += Dir["#{File.dirname(__FILE__)}/../files/locales/*"]
