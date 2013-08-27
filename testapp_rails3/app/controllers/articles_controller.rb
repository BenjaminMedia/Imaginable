class ArticlesController < ApplicationController
	respond_to :html, :json

	def index
		if params[:admin]
			@articles = Article.order(:published_at).reverse
		else
			@articles = Article.published.order(:published_at).reverse
		end
		respond_with @articles
	end

	def show
		@article = Article.find(params[:id])
		respond_with @article
	end

	def new
		@article = Article.new
	end

	def create
		@article = Article.new(params[:article])
		@article.published_at = Time.now
		@article.save!
		respond_to {|format|
			format.html { redirect_to @article }
			format.json { respond_with @article }
		}
	end

	def edit
		@article = Article.find(params[:id])
	end

	def update
		@article = Article.find(params[:id])
		@article.update_attributes!(params[:article])
		respond_to {|format|
			format.html { redirect_to @article }
			format.json { respond_with @article }
		}
	end

	def delete
		@article = Article.find(params[:id])
	end

	def destroy
		@article = Article.find(params[:id])
		@article.destroy
		repond_to {|format|
			format.html { redirect_to article_index }
			format.json { respond_with true }
		}
	end
end
