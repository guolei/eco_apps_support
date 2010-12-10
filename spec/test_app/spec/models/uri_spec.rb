require 'spec_helper'

describe "Extensions" do
  describe "URI" do
    describe "add_query" do
      it "should add query to url" do
        URI.parse("http://article.com").add_query({:q => 5}).to_s.should == "http://article.com?q=5"
        URI.parse("https://article.com?p=1").add_query({:q => 5, :t=>"hello"}).to_s.should == "https://article.com?p=1&q=5&t=hello"
      end

      it "should not add query if value is null" do
        URI.parse("http://article.com").add_query({:q => nil}).to_s.should == "http://article.com"
        URI.parse("http://article.com?p=5").add_query({:q => nil, :t => 3}).to_s.should == "http://article.com?p=5&t=3"
      end

      it "should replace existing one" do
        URI.parse("http://article.com?p=5").add_query({:p=>6, :t => 3}).to_s.should == "http://article.com?p=6&t=3"
      end
    end

    describe "remove_query" do
      it "should remove query from url" do
        URI.parse("http://article.com").remove_query(:s).to_s.should == "http://article.com"
        URI.parse("http://article.com?t=5&q=6").remove_query(:q,:w).to_s.should == "http://article.com?t=5"
      end
    end

    describe "parse_query" do
      it "should have params" do
        URI.parse("http://article.com").params.should == {}
        URI.parse("http://article.com?t=5&q=hello").params.should == {:t=>"5", :q=>"hello"}.with_indifferent_access
      end
    end
  end
end