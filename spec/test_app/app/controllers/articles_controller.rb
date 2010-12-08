class ArticlesController < ApplicationController
  def index
    @articles = Article.combo_search(params)
  end

  def show
   
  end
end
