require 'uuidtools'

module Imaginable
  module FormBuilder

    def self.included(base)
      base.extend(ClassMethods)
    end

    def image_field(method, options = {})
      has_existing_image = @object.method("has_#{method}?").call
      if has_existing_image
        image = @object.method(method).call
      else
        image = Imaginable::Image.new
        @object.send("#{method}=", image)
      end

      ActionView::Helpers::InstanceTag.new(@object_name, method, self, @object).to_image_field_tag(options) do |tag|
        self.fields_for method, @object do |f|
          tag << f.hidden_field(:uuid,   :value => image.uuid)
          tag << f.hidden_field(:token,  :value => image.token)
          tag << f.hidden_field(:width,  :value => image.width)
          tag << f.hidden_field(:height, :value => image.height)
        end
      end
    end

    module ClassMethods

    end

  end

  module InstanceTag
    include Rails.application.routes.url_helpers

    def self.included(base)
      base.extend(ClassMethods)
    end

    def to_image_field_tag(options = {})
      image = @object.send(method_name)
      has_existing_image = !image.new_record?

      options[:preview_width] ||= 500

      ### XXX: Hard-coded, because URL helpers aren't easily available here.
      upload_url = "/imaginable/images/#{image.uuid}"

      dom_prefix = "#{@object_name}_#{@method_name}_attributes"
      tag_text = content_tag('div', :id => "#{dom_prefix}_container", :class => "imaginable",
        :'data-imaginable-prefix' => dom_prefix,
        :'data-imaginable-app-host' => Imaginable.app_host,
        :'data-imaginable-upload-url' => upload_url,
        :'data-imaginable-preview-width' => options[:preview_width],
        :'data-imaginable-force-crop' => options[:force_crop],
        :'data-imaginable-crop' => options[:crop],
        :'data-imaginable-has-image' => has_existing_image,
        :'data-imaginable-crop-ratio' => (Imaginable.named_ratios[options[:crop]] || 0)) {
          sub_tag_text = build_imaginable_crop_content(options)

          if has_existing_image
            sub_tag_text << tag('img', :id => "#{dom_prefix}_preview_image", :src => image.url(:crop => options[:crop], :width => options[:preview_width], :height => options[:preview_height]), :class => "imaginable_preview_image")
          else
            sub_tag_text << tag('img', :id => "#{dom_prefix}_preview_image", :src => '/images/blank.gif', :style => 'display:none;', :class => "imaginable_preview_image")
          end

          sub_tag_text << content_tag('div', :id => "#{dom_prefix}_file_list", :class => "imaginable_file_list") { "" }
          sub_tag_text << content_tag('a', :id => "#{dom_prefix}_browse_button", :class => 'imaginable_browse_files_button', :href => '#') { "Select file" }
          sub_tag_text << content_tag('a', :id => "#{dom_prefix}_crop_button", :class => 'imaginable_crop_button',
            :href => "#", :style => "display:none;") { "Crop Image" }
          yield sub_tag_text if block_given?
          sub_tag_text
      }
    end

    def build_imaginable_crop_content(options = {})
      has_existing_image = @object.method("has_#{method_name}?").call
      if has_existing_image
        image = @object.method("#{method_name}").call
      end

      dom_prefix = "#{@object_name}_#{@method_name}"

      container_div = content_tag('div', :style => 'display:none', :class => 'imaginable_crop_container') {
        content_div = content_tag('div', :id => "#{dom_prefix}_imaginable_crop_content", :class => 'imaginable_crop_content') {
          content_div_content = content_tag('div', :id => "#{dom_prefix}_imaginable_crop_header", :class => 'imaginable_crop_header') {"Crop Image"}
          content_div_content << content_tag('div', :id => "#{dom_prefix}_imaginable_crop_description", :class => 'imaginable_crop_description') {"Please crop your image by dragging the corners of the crop-selection."}
          if has_existing_image
            content_div_content << tag('img', :id => "#{dom_prefix}_imaginable_crop_image", :class => 'imaginable_crop_image', :src => image.url(:crop => 'none', :width => 500, :height => 500))
          else
            content_div_content << tag('img', :id => "#{dom_prefix}_imaginable_crop_image", :class => 'imaginable_crop_image', :src => '/images/blank.gif')
          end
          content_div_content << content_tag('div', :id => "#{dom_prefix}_imageinable_crop_buttons", :class => 'imaginable_crop_buttons') {
            buttons_div_tag = content_tag('a', :id => "#{dom_prefix}_imaginable_cancel_crop_button", :class => 'imaginable_cancel_crop_button', :href => '#') {"Cancel"}
            buttons_div_tag << content_tag('a', :id => "#{dom_prefix}_imaginable_save_crop_button", :class => 'imaginable_save_crop_button', :href => '#') {"Save"}
          }
        }
      }
    end

    module ClassMethods

    end

  end

  module FormtasticFormBuilder

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

    end

  end
end
