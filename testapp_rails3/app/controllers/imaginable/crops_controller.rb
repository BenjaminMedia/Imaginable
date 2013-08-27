class Imaginable::CropsController < ApplicationController
	before_filter :find_image_and_crop

	respond_to :json

	def ratio
		if params[:crop].is_a?(String) && params[:crop].size < 128
			sym = params[:crop].intern
			named_ratio = Imaginable.named_ratios[sym]
			respond_with named_ratio
		end
		respond_with nil
	end

	def show
		if params[:token] == @image.token
			respond_with @crop
		else
			permission_denied
		end
	end

	def update
		if params[:token] == @image.token
			@crop.update_attributes!(params[:crop])
			respond_with @crop
		else
			permission_denied
		end
	end

	def destroy
		if params[:token] == @image.token
			@crop.destroy
			respond_with true
		else
			permission_denied
		end
	end

	def create
		if params[:token] == @image.token
			@crop.update_attributes!(params[:crop])
			respond_with @crop
		else
			permission_denied
		end
	end

	private
	def find_image_and_crop
		@image = Imaginable::Image.where(:uuid => params[:image_id]).first
		raise ActiveRecord::RecordNotFound.new unless @image
		@crop = @image.get_or_initialize_named_crop(params[:id])
	end

	def permission_denied
		render :text => '401 Unauthorized', :status => :unauthorized
	end
end
