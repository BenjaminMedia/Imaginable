module Imaginable
  module FormBuilder 
    
    def self.included(base)  
      base.extend(ClassMethods)
    end
    
    def image_field(method, options = {})
      tag_text = hidden_field("#{method}_uuid")
      tag_text << hidden_field("#{method}_token")
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
      options[:preview_width] ||= 50
      dom_prefix = "#{@object_name}_#{@method_name}"
      tag_text = content_tag('div', :id => "#{dom_prefix}_container") {
        sub_tag_text = ""
        
        if @object.method("has_#{method_name}?").call
          image = @object.method("#{method_name}").call
          sub_tag_text = tag('img', :id => "#{dom_prefix}_preview_image", :src => image.url(:width => options[:preview_width]))
        else
          sub_tag_text = tag('img', :id => "#{dom_prefix}_preview_image", :src => '/images/blank.gif')
        end
        
        sub_tag_text << content_tag('div', :id => "#{dom_prefix}_file_list") { "" }
        sub_tag_text << content_tag('a', :id => "#{dom_prefix}_browse_button", 
          :href => '#',
          :'data-imaginable-prefix' => dom_prefix,
          :'data-imaginable-upload-server' => Imaginable.upload_server,
          :'data-imaginable-scale-server' => Imaginable.scale_server,
          :'data-imaginable-preview-width' => options[:preview_width]) { "[Browse files]" }
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