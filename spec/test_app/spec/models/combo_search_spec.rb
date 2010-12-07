require 'spec_helper'

describe "ComboSearch" do

  before do
    Time.zone = "Beijing"
    @a1 = Factory(:article, :title => "one", :published => true, :created_at => Time.parse("2010-11-01 09:00:00"))
    @a2 = Factory(:article, :title => "two", :published => true, :created_at => Time.parse("2010-11-01 14:00:00"))
    @a3 = Factory(:article, :title => "three", :created_at => Time.parse("2010-11-03 21:00:00"))

    @c1 = Factory(:comment, :article => @a1, :score => 5, :title => "first")
    @c2 = Factory(:comment, :article => @a1, :score => 10, :title => "second")
    @c3 = Factory(:comment, :article => @a2, :score => 8, :title => "third")
  end

  describe "combo_search" do
    it "should find all by default" do
      Article.combo_search({}).should == [@a1, @a2, @a3]
      Article.combo_search({}, :default => :none).should == []
    end

    it "should paginate results" do
      Article.combo_search({}, :per_page => 1).should == [@a1]
      Article.combo_search({}, :per_page => 1, :page => 2).should == [@a2]
    end

    it "should search by one column" do
      Article.combo_search({:title => "one"}).should == [@a1]
      Article.combo_search("title like 't%'", :conditions=>{:published => true}).should == [@a2]
    end

    it "should search by a range of value" do
      Article.combo_search({:created_at => {:from => "2010-11-01", :to => "2010-11-02"}}).should == [@a1, @a2]
      Article.combo_search({:created_at => {:to => "2010-11-02"}}).should == [@a1, @a2]
      Article.combo_search({:created_at => {:from => "2010-11-02"}}).should == [@a3]
    end

    it "should search by am/pm" do
      Article.combo_search({:created_at => {:from => "2010-11-01", :ampm => "am"}}).should == [@a1]
      Article.combo_search({:created_at => {:from => "2010-11-01", :ampm => "pm"}}).should == [@a2, @a3]
    end

    it "should search by whether is null" do
      Article.combo_search({:created_at => {:is_null => true}}).should == []
      Article.combo_search({:created_at => {:is_null => false}}).should == [@a1, @a2, @a3]
    end

    it "should search by multiple columns" do
      Article.combo_search({:title => "two", :created_at => {:ampm=>"am"}}).should == []
    end

    it "should accept additional conditions" do
      Article.combo_search({:created_at => {:ampm=>"pm"}}, :conditions=>{:published => false}).should == [@a3]
    end

    it "should accept joins" do
      Article.combo_search({"comments.title" => "second"}, :joins => :comments).should == [@a1]
      Article.combo_search({"comments.score" => {:from => 7, :to => 9}}, :joins => :comments).should == [@a2]
    end

    it "should accept includes" do
      Article.combo_search({:title => "two"}, :includes => :comments).should == [@a2]
    end

    it "should accept order" do
      Article.combo_search({:published => true}, :order => "id desc").should == [@a2, @a1]
    end

    it "should define customized hash role" do
      class NightSqlHash < EcoAppsSupport::ComboSearch::SqlHash
        match :night, :datetime do |column|
          "#{ActiveRecord::Base.convert_tz(column, "%H")} >= 20"
        end
      end
      Article.combo_search({:created_at => {:night => true}}).should == [@a3]
    end

    it "should accept block" do
      c = Article.combo_search({:created_at => {:morning => true}, :published=>true}){|hash|
        hash.match :morning, :datetime do |column|
          "#{ActiveRecord::Base.convert_tz(column, "%H")} <= 12"
        end
      }
      c.should == [@a1]
    end
  end
end
