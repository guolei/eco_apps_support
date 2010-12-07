require 'spec_helper'

describe "Extensions" do

  describe "ActiveRecord" do

    before do
      @article = Factory(:article)
    end

    it "should have dom_id" do
      @article.dom_id.should == "article_#{@article.id}"
      @article.dom_id("list").should == "list_article_#{@article.id}"
    end

    describe "days_between" do
      it "should be available both for object and class" do
        @article.days_between("2010-11-01", "2010-11-08").should == 7
        Article.days_between("2010-11-01", "2010-11-08").should == 7
      end

      it "should ignore weekend" do
        @article.days_between("2010-11-01", "2010-11-08", true).should == 5
      end
    end

    describe "convert_tz" do
      it "should convert datetime field" do
        @article.convert_tz(:created_at).should == "DATE_FORMAT(CONVERT_TZ(created_at, '+00:00', '+00:00'),'%Y-%m-%d')"
        @article.convert_tz(:created_at, :month).should == "DATE_FORMAT(CONVERT_TZ(created_at, '+00:00', '+00:00'),'%Y-%m')"
      end

      it "should convert according to time zone" do
        Time.zone="Beijing"
        @article.convert_tz(:created_at).should == "DATE_FORMAT(CONVERT_TZ(created_at, '+00:00', '+08:00'),'%Y-%m-%d')"
      end
    end

    describe "day_condition_for" do
      it "should be the time between the beginning and the end of day" do
        Article.day_condition_for("2010-10-01").should == ["created_at >= ? and created_at < ?", "2010-10-01".to_time.in_time_zone.beginning_of_day,"2010-10-01".to_time.in_time_zone.end_of_day]
      end
    end

    describe "find_column_by_name" do
      it "should find column of itself" do
        Article.find_column_by_name(:title).type.should == :string
        Article.find_column_by_name(:no_exist).should be_nil
      end

      it "should find column of others" do
        Article.find_column_by_name("comments.content").type.should == :string
        Article.find_column_by_name("comments.no_exist").should be_nil
      end
    end
  end

end
