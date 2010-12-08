require 'spec_helper'

describe "SearchForm" do

  describe "search_form_for" do

    it "should create date time span select for datetime field" do
      helper.search_form_for(Article, :created_at,:title, [:updated_at, {:ampm=>true}], :published,
        [:published_at, {:null_check => true}], [:id, {:range => true}], ["comments.score", {:collection=>[1,3,5]}], :simple => 2, :url => "/articles")
    end

    it "should have search_tag" do
      helper.search_tag("/articles", "Name or Title")
      helper.search_tag("/articles", "Name or Title", :remote => true)
    end
  end

end

