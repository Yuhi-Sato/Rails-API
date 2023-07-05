class ArticlesController < ApplicationController
  def index
    @articles = Article.first(10)
    render json: @articles
  end
end