class ArticlesController < ApplicationController
  def index
    @articles = Article.combo_search(params, :joins => :comments)
  end

  def show
   
  end
end
