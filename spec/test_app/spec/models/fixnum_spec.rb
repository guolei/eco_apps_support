require 'spec_helper'

describe "Extensions" do

  describe "Fixnum" do

    describe "to_formatted_time" do

      it "should convert to time" do
        159.to_formatted_time.should == "2:39"
        159.to_formatted_time(false).should == "0:02"
        1149.to_formatted_time.should == "19:09"
        3690.to_formatted_time.should == "1:01:30"
        3690.to_formatted_time(false).should == "1:01"
      end

    end

    describe "to_time_zone" do
      it "should get time_zone by number" do
        8.to_time_zone.name.should == "Beijing"
      end
    end

  end

end