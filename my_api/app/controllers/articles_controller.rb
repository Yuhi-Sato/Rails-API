class ArticlesController < ApplicationController
  def index
    @articles = Article.first(10)
    render json: @articles
  end

  def create
    @article = Article.create(article_params)
    render json: @article
  end

  private
  def article_params
    params.require(:article).permit(:title,:body)
  end
end