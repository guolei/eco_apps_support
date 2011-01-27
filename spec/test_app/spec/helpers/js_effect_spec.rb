require 'spec_helper'

describe "Tags" do

  describe "jquery_include_tag" do
    it "should load once" do
      helper.jquery_include_tag(:ui, :css).should == "<script src=\"https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.6/jquery-ui.min.js\" type=\"text/javascript\"></script><link href=\"https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.6/themes/base/jquery-ui.css\" media=\"screen\" rel=\"stylesheet\" type=\"text/css\" />"
      helper.jquery_include_tag(:ui, :css).should == ""
    end
  end

  describe "document_ready" do
    it "should accept both params and block" do
      helper.document_ready("alert('hi')").should == "$(document).ready(function(){alert('hi')});"
      helper.document_ready{"alert('hi')"}.should == "$(document).ready(function(){alert('hi')});"
    end
  end

  describe "popup" do

    before do
      helper.stub!(:rand).and_return(10)
    end

    it "should accept params" do
      helper.popup("hello", "/articles").should == helper.link_to("hello", "/articles", :class=>"box_10") + javascript_tag(helper.document_ready{%{$(".box_10").colorbox({width:'60%', title:'hello'});}})
      helper.popup("hello", "/articles", :title => "hello", :height=>"80%").should == helper.link_to("hello", "/articles", :class=>"box_10", :title=>"hello") + javascript_tag(helper.document_ready{%{$(".box_10").colorbox({width:'60%'});}})
      helper.popup("hello", "/articles", :width=>600, :iframe=>true).should == helper.link_to("hello", "/articles", :class=>"box_10") + javascript_tag(helper.document_ready{%{$(".box_10").colorbox({width:600, height:"60%", iframe:true});}})
    end

    it "should popup inline" do
      helper.popup("hello", "#articles").should == helper.link_to("hello", "#", :class=>"box_10") + javascript_tag(helper.document_ready{%{$(".box_10").colorbox({width:"60%", height:"60%", inline:true, href:"#articles"});}})
    end
  end

  describe "ajax_load" do
    it "should load url" do
      helper.ajax_load("/article/10")
    end
  end
end

