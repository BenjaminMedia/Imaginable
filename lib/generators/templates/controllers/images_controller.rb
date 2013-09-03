class Imaginable::ImagesController < ApplicationController
	respond_to :json
	before_filter :find_or_initialize_image, :except => [:create]

	def show
		respond_to { |format|
			format.json { respond_with @image, :include => :crops }
			format.jpg  { redirect_to @image.url }
		}
	end

	def create
		file = params[:file].tempfile
		@image = Imaginable.upload(file.path, :ext => ext_for(params[:file]))
		respond_with @image
	end

	def info
		(permission_denied; return) unless @image.authorize_token?(params[:token])
		respond_with @image, :include => :crops
	end

	def webhook
		(permission_denied; return) unless @image.authorize_token?(params[:token])

		# TODO: Set width/height from CDN webhook data
		respond_with true
	end

	def update
		(permission_denied; return) unless @image.authorize_token?(params[:token])
		file = params[:file].tempfile
		@image.upload!(file, :ext => ext_for(params[:file]))
		render :json => @image
	end

	def destroy
		(permission_denied; return) unless @image.authorize_token?(params[:token])
		response = Imaginable.cdn.delete_object(:path => "/#{@image.uuid}")
		logger.info response.inspect
		respond_with true
	end

	private
	def find_or_initialize_image
		@image = Imaginable::Image.where(:uuid => params[:id]).first
		unless @image
			@image = Imaginable::Image.new { |img| img.uuid = params[:id] }
			permission_denied unless @image.authorize_token?(params[:token])
		end
		@image
	end

	def permission_denied
		render :text => '401 Unauthorized', :status => :unauthorized
	end

	def detect_mimetype(file_data)
	  if file_data.content_type.strip == "application/octet-stream"
	    return MIME::Types.type_for(file_data.original_filename)[0]
	  else
	  	puts file_data.content_type.inspect
	    return MIME::Types[file_data.content_type].first
	  end
	end

	def ext_for(file_data)
	  mime = detect_mimetype(file_data)
	  return '.jpg' if mime.simplified == 'image/jpeg'
	  '.' + mime.extensions.first
	end
end