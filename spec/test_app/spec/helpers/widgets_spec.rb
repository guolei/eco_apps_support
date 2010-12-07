require 'spec_helper'

describe "Widgets" do

  describe "calendar_view" do
    it "should show calendar view" do
      helper.calendar_view{|day| day}
    end
  end

  describe "idp_table_for" do
    before do
      30.times{Factory(:article)}
      @articles = Article.combo_search({})
      helper.stub!(:url_for).and_return("/articles")
    end

    it "should list items" do
      helper.list_table_for @articles do |item, col|
        col.add :id, :order => "id"
        col.build :title, :created_at
      end
    end

    it "should accept options" do
      helper.list_table_for @articles, :searchable => true, :sortable => true, :update=>"list" do |item, col|
        col.add :id, :order => "id"
        col.build :title, :created_at
      end
    end
  end
end

