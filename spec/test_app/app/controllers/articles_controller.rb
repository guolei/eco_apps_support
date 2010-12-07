class ArticlesController < ApplicationController
  def index
    @articles = Article.combo_search(params[:q]||{})
  end

  def show
   
  end
end
