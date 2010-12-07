class String
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::TagHelper

  def to_html(&block)
    str = simple_format(self)
    str = block.call(str) if block_given?
    StringFormatter.format(str)
  end
     
end

class StringFormatter

  class << self
    def subclasses
      @subclasses ||= []
    end

    def inherited(base)
      subclasses << base
    end

    def format(str)
      subclasses.each do |klass|
        str = klass.format(str)
      end
      str
    end
  end

end