class Imaginable::ImagesController < ApplicationController
	before_filter :find_image, :except => [:create]

	respond_to :json, :jpg

	def show
		respond_to { |format|
			format.json { respond_with @image, :include => :crops }
			format.jpg  { redirect_to @image.url }
		}
	end

	def create
		file = params[:file].tempfile
		@image = Imaginable.upload(file.path)
		respond_with @image
	end

	def info
		if params[:token] == @image.token
			respond_with @image
		else
			permission_denied
		end
	end

	def webhook
		if params[:token] == @image.token
			# TODO: Set width/height from CDN webhook data
			respond_with true
		else
			permission_denied
		end
	end

	def update
		if params[:token] == @image.token
			file = params[:file].tempfile
			@image.upload!(file)
		else
			permission_denied
		end
	end

	def destroy
		if params[:token] == @image.token
			response = Imaginable.cdn.delete_object(:path => "/#{@image.uuid}")
			logger.info response.inspect
			respond_with true
		else
			permission_denied
		end
	end

	private
	def find_image
		@image = Imaginable::Image.where(:uuid => params[:id]).first
	end

	def permission_denied
		render :text => '401 Unauthorized', :status => :unauthorized
	end
end