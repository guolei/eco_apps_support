require 'spec_helper'

describe "Extensions" do
  describe "String" do
    describe "to_html" do
      it "should convert simple" do
        "basic text\nwith a line break.".to_html.should == "<p>basic text\n<br />with a line break.</p>"
      end

      it "should call block" do
        "hello world".to_html{|str| str.gsub(/o/,"i")}.should == "<p>helli wirld</p>"
      end

      it "should call subclass of StringFormatter" do
        class MyFormatter < StringFormatter
          def self.format(str)
            str.gsub(/hello/, "haha")
          end
        end
        "hello world".to_html.should == "<p>haha world</p>"
      end
    end
  end
end