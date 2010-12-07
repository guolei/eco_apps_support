require 'spec_helper'

describe "articles/index.html.erb" do
  before do
    I18n.locale = :en
    Time.zone = "Beijing"
  end

  describe "i18n extension" do

    it "should translate by folder" do
      view.stub!(:params).and_return(:controller => "articles", :action => "index") 
      view.t(:hello).should == "Hello World"
      view.t(:hi).should == "Hiya"
      view.t(:missing).should == "Missing"
      view.t(:total_record, :count => 2).should == "2 records found"
    end

  end

  describe "date format" do

    it "should convert time" do
      time = Time.parse("2010-11-01 09:30:36")
      time_in_zone = Time.zone.parse("2010-11-01 09:30:36")
      date = Date.parse("2010-11-01")
      time.to_s(:db).should == "2010-11-01 09:30:36"
      time.to_s(:long).should == "2010-11-01 09:30"
      time_in_zone.to_s(:date).should == "2010-11-01"
      date.to_s(:date).should == "2010-11-01"
      I18n.locale = :zh
      time.to_s(:only_date).should == "11月1日"
    end
  end
end
