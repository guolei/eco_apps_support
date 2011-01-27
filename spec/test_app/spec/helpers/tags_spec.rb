require 'spec_helper'

describe "Tags" do

  describe "active_link_to" do
    it "generate link with class" do
      helper.active_link_to("label", "/").should == "<li>#{link_to("label", "/")}</li>"
    end
  end
end

