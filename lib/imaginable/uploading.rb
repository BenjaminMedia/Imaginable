require 'mime/types'

module Imaginable
  module Uploading
    class UploadError < RuntimeError; end

    module ClassMethods
      def upload(path, options = {})
        image = self.new
        image.upload!(path, options)
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    def upload!(path, options = {})
      options[:destination_path] = '/'
      options[:source_file_path] = path
      options[:async] ||= false
      if options[:async]
        options[:webhook_url] = imaginable_image_webhook_url(self, :token => self.token)
        options[:webhook_format] = :json
      end
      ext = options[:ext] || File.extname(path)
      options[:destination_file_name] = "#{self.uuid}#{ext}"
      response = Imaginable.cdn.upload(options)
      if response.files && response.files.any? && response.files.first['upload_success']
        unless options[:async]
          r = response.files.first
          write_attribute(:width, r['width'])
          write_attribute(:height, r['height'])
        end
        save!
        return self
      else
        if response.files && response.files.any?
          message = response.files.first['name'].to_s + ": " + response.files.first['msgs'].map{|msg| msg['text']}.join("; ")
        else
          message = response.msgs.join("\n")
        end
        raise UploadError, message
      end
    end
  end
end