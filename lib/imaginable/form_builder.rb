require 'uuidtools'

module Imaginable
  module FormBuilder

    def self.included(base)
      base.extend(ClassMethods)
    end

    def image_field(method, options = {})
      tag_text = hidden_field("#{method}_uuid")
      tag_text << hidden_field("#{method}_token")
      tag_text << hidden_field("#{method}_version")
      tag_text << ActionView::Helpers::InstanceTag.new(@object_name, method, self, @object).to_image_field_tag(options)
    end

    module ClassMethods

    end

  end

  module InstanceTag

    def self.included(base)
      base.extend(ClassMethods)
    end

    def to_image_field_tag(options = {})
      has_existing_image = @object.method("has_#{method_name}?").call
      if has_existing_image
        image = @object.method("#{method_name}").call
      end

      options[:preview_width] ||= 0
      options[:preview_height] ||= 0

      dom_prefix = "#{@object_name}_#{@method_name}"
      tag_text = content_tag('div', :id => "#{dom_prefix}_container", :class => "imaginable",
        :'data-imaginable-prefix' => dom_prefix,
        :'data-imaginable-upload-server' => Imaginable.upload_server,
        :'data-imaginable-scale-server' => Imaginable.scale_server,
        :'data-imaginable-preview-width' => options[:preview_width],
        :'data-imaginable-force-crop' => options[:force_crop],
        :'data-imaginable-format' => options[:format],
        :'data-imaginable-new-version' => "'#{UUIDTools::UUID.timestamp_create.to_i.to_s}'") {
          sub_tag_text = build_imaginable_crop_content(options)

          if has_existing_image
            sub_tag_text << tag('img', :id => "#{dom_prefix}_preview_image", :src => image.url(:format => options[:format], :width => options[:preview_width], :height => options[:preview_height]), :class => "imaginable_preview_image")
          else
            sub_tag_text << tag('img', :id => "#{dom_prefix}_preview_image", :src => '/images/blank.gif', :style => 'display:none;', :class => "imaginable_preview_image")
          end

          sub_tag_text << content_tag('div', :id => "#{dom_prefix}_file_list", :class => "imaginable_file_list") { "" }
          sub_tag_text << content_tag('a', :id => "#{dom_prefix}_browse_button", :class => 'imaginable_browse_files_button', :href => '#') { "Select file" }
          sub_tag_text << content_tag('a', :id => "#{dom_prefix}_crop_button", :class => 'imaginable_crop_button',
            :href => "##{dom_prefix}_imaginable_crop_content", :style => "display:none;") { "Crop Image" }
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
            content_div_content << tag('img', :id => "#{dom_prefix}_imaginable_crop_image", :class => 'imaginable_crop_image', :src => image.url(:format => 'none', :width => 500, :height => 500))
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
