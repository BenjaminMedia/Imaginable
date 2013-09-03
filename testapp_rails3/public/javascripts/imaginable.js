(function($){

  var Imaginable = function(element, options) {
    // ELEMENTS - Main
    var main_elem = $(element);
    var uploader_elem;
    var cropper_elem;
    // ELEMENTS - Uploader
    var file_list_elem;
    var preview_image_elem;
    // ELEMENTS - Cropper
    var crop_image_elem;
    var save_crop_button_elem;
    var cancel_crop_button_elem;

    // FORM ELEMENTS
    var uuid_field;
    var token_field;
    var width_field;
    var height_field;

    // SETTINGS
    var settings = $.extend({
      prefix:              main_elem.data('imaginable-prefix'),
      appHost:             main_elem.data('imaginable-app-host'),
      uploadUrl:           main_elem.data('imaginable-upload-url'),
      preview_width:       main_elem.data('imaginable-preview-width')    || 250,
      enable_cropping:     main_elem.data('imaginable-enable-cropping')  || true,
      force_crop:          main_elem.data('imaginable-force-crop')       || false,
      crop:                main_elem.data('imaginable-crop')             || 'original',
      cropRatio:           parseFloat(main_elem.data('imaginable-crop-ratio') || '0'),

      force_crop:          main_elem.data('imaginable-force-crop')       || false,

      runtimes:            'html5,flash,silverlight',
      max_file_size:       '10mb',
      file_data_name:      'image_file',
      multipart:           true,
      auto_start:          true,
      flash_swf_url:       '/javascripts/plupload.flash.swf',
      silverlight_xap_url: '/javascripts/plupload.silverlight.xap',
      filters: [
        {title: "Image files", extensions: "jpg,gif,png,jpeg"},
      ]
    }, options || {});

    // INSTANCE
    var obj = this;

    // INSTANCE VARIABLES - Shared
    var existing_image = main_elem.data('imaginable-has-image') !== 'false';
    var image_version;

    // INSTANCE VARIABLES - Uploader
    var uploader;
    var current_image_uuid;
    var current_image_token;
    var current_image_width;
    var current_image_height;

    // INSTANCE VARIABLES - Cropper
    var cropper;
    var current_crop_points = null;

    // Public methods
    this.hostForUUID = function(uuid) {
      var s = ((uuid.charCodeAt(0) % 6) + 1).toString();
      var host = 's' + s + "." + settings.appHost;
      return host;
    }

    this.croppedImageURI = function(uuid, width, height, format) {
       height = typeof height !== 'undefined' ? height : 0;
       format = typeof format !== 'undefined' ? format : 'jpg';
       var host = this.hostForUUID(uuid);
       var url = "http://" + host + "/" + uuid + "." + format;
       var crop_string = "crop=" + current_crop_points.x1 + "px," + current_crop_points.y1 + "px," + current_crop_points.x2 + "px," + current_crop_points.y2 + "px";
       var scale_string = "width=" + width + "&" + "height=" + height + "&mode=max";
       return url + "?" + crop_string + "&" + scale_string;
    }

    this.originalImageURI = function(uuid, width, height, format) {
      height = typeof height !== 'undefined' ? height : 0;
      format = typeof format !== 'undefined' ? format : 'jpg';
      var host = this.hostForUUID(uuid);
      var url = "http://" + host + "/" + uuid + "." + format;
      return url;
    }

    this.refreshPreviewImage = function() {
      var preview_url = this.croppedImageURI(current_image_uuid, settings.preview_width);

      preview_image_elem.attr('src', preview_url).load(function() {
        preview_image_elem.fadeIn();
        uploader.refresh();
      });
    }

    this.refreshCroppingPreviewImage = function() {
      var crop_preview_url = this.originalImageURI(current_image_uuid, 600, 600, 'jpg');

      crop_image_elem.attr('src', crop_preview_url).load(function() {
        if (settings.force_crop == true)
          obj.showCropDialog();
      });
    }

    this.showCropDialog = function() {
      var crop_container = main_elem.find('.imaginable_crop_container').first();
      var crop_content = main_elem.find('.imaginable_crop_content').first();

      $.fancybox({
        content: crop_content.html(),
        modal: false,
        width: 600,
        height: 670,
        autoSize: false,
        afterShow: function() {
          var crop_points = getCropPoints();
          var img_elm = $('.fancybox-wrap .imaginable_crop_image');

          cropper = img_elm.imgAreaSelect({
             handles: true,
             instance: true,
             imageHeight: current_image_height,
             imageWidth: current_image_width,
             onSelectEnd: onAreaSelectorSelectEnd
          });

          if (settings.crop != 'none')
            cropper.setOptions({cropRatio: settings.cropRatio});

          cropper.setSelection(crop_points['x1'],crop_points['y1'],crop_points['x2'],crop_points['y2'],false);
          cropper.setOptions({ show: true });
          cropper.update();
        },
        afterClose: function() {
          cropper.setOptions({ hide: true });
          cropper.update();
        }
      });
    };

    this.saveCropping = function() {
      var crop_points = getCropPoints();

      var name = settings.crop;
      var x = crop_points['x1'];
      var y = crop_points['y1'];
      var width = crop_points['width'];
      var crop_data = {};
      crop_data['x'] = x
      crop_data['y'] = y
      crop_data['w'] = width;
      var data = {_method: 'PUT', crop: crop_data, callback: '?', token: current_image_token};

      var url = '/imaginable/images/' + current_image_uuid + '/crops/' + name;

      $.ajaxSetup({
        headers: {
          "X-CSRF-Token": $("meta[name='csrf-token']").attr('content')
        }
      });

      $.ajax({
        type: 'POST',
        url: url,
        data: data,
        dataType: 'json',
        success: onCroppingSaved
      });

      writeToFormFields();
    };

    // Private methods
    var initialize = function() {
      initializeElements();
      initializeButtons();
      initializeUploader();
      initializeCropper();
    };

    var initializeElements = function() {
      uuid_field   = main_elem.find('#' + settings.prefix + "_uuid").first();
      token_field  = main_elem.find('#' + settings.prefix + "_token").first();
      width_field  = main_elem.find('#' + settings.prefix + "_width").first();
      height_field = main_elem.find('#' + settings.prefix + "_height").first();
      current_image_uuid = uuid_field.val();
      current_image_token = token_field.val();
      current_image_width = width_field.val();
      current_image_height = height_field.val();

      // Uploader
      uploader_elem = main_elem.find('.imaginable_browse_files_button').first();
      file_list_elem = main_elem.find('.imaginable_file_list').first();
      preview_image_elem = main_elem.find('.imaginable_preview_image').first();

      // Cropper
      cropper_elem = main_elem.find('.imaginable_crop_button').first();

      crop_image_elem = main_elem.find('.imaginable_crop_image').first();
      save_crop_button_elem = main_elem.find('.imaginable_save_crop_button').first();
      cancel_crop_button_elem = main_elem.find('.imaginable_cancel_crop_button').first();
    }

    var initializeButtons = function() {
      // Cropper
      $(document).on('click', '.imaginable_save_crop_button', onSaveCropButtonClick);
      $(document).on('click', '.imaginable_cancel_crop_button', onCancelCropButtonClick);
    };

    var initializeUploader = function() {
      var multipart_options = {
        _method: 'PUT',
        token: current_image_token
      };

      uploader = new plupload.Uploader({
        runtimes:             settings['runtimes'],
        browse_button:        uploader_elem.attr('id'),
        container:            uploader_elem.parent().first().attr('id'),
        max_file_size:        settings['max_file_size'],
        url:                  settings['uploadUrl'],
        file_data_name:       'file',
        multipart:            settings['multipart'],
        multipart_params:     multipart_options,
        flash_swf_url:        settings['flash_swf_url'],
        silverlight_xap_url:  settings['silverlight_xap_url'],
        filters:              settings['filters']
      });

      uploader.init();

      uploader.bind('FilesAdded', onUploaderFilesAdded);
      uploader.bind('FilesRemoved', onUploaderFilesRemoved);
      uploader.bind('UploadProgress', onUploaderUploadProgress);
      uploader.bind('Error', onUploaderError);
      uploader.bind('FileUploaded', onUploaderFileUploaded);
      uploader.bind('UploadComplete', onUploaderUploadComplete);
    };

    var initializeCropper = function() {
      main_elem.find('.imaginable_crop_button').first().bind('click', onCropperElemClick);

      if (existing_image) {
        downloadImageMetadata();
      }
    };

    var onCropperElemClick = function(event) {
      event.preventDefault();
      obj.showCropDialog();
    };

    var changeImageVersion = function(version) {
      image_version = version;
      writeToFormFields();
    };

    var getCropPoints = function() {
      if (current_crop_points != null)
        return current_crop_points;

      current_crop_points = {x1: 0, x2: current_image_width, y1: 0, y2: current_image_height, width: current_image_width, height: current_image_height};

      if (settings.format != 'none') {
        var numeric_crop_ratio = settings.cropRatio;
        if (numeric_crop_ratio > 1) {
          // Width > Height
          current_crop_points['x2'] = current_image_width;
          current_crop_points['y2'] = Math.round(current_image_width * numeric_crop_ratio);
          current_crop_points['height'] = current_crop_points['y2'];
        } else {
          // Width < Height || Width == Height
          current_crop_points['y2'] = current_image_height;
          current_crop_points['x2'] = Math.round(current_image_height / numeric_crop_ratio);
          current_crop_points['width'] = current_crop_points['x2'];
        }
      }

      return current_crop_points;
    };

    var resetCropPoints = function() {
      current_crop_points = null;
      current_scaled_crop_points = null;
    };

    var showCropButton = function() {
      cropper_elem.fadeIn();
    };

    var numericAspectRatio = function() {
      if (settings.crop == 'original') {
        return current_image_height / current_image_width;
      } else if (settings.crop != 'none') {
        return settings.cropRatio;
      } else {
        return 0;
      }
    };

    var writeToFormFields = function() {
      uuid_field.val(current_image_uuid);
      uuid_field.trigger('change');
      token_field.val(current_image_token);
      token_field.trigger('change');
      width_field.val(current_image_width);
      width_field.trigger('change');
      height_field.val(current_image_height);
      height_field.trigger('change');
    };

    var onDownloadImageMetadataComplete = function(data) {
      current_image_width = data.image.width;
      current_image_height = data.image.height;

      // Make sure that crop points are initialized
      getCropPoints();

      var crop = undefined;
      $.each(data.image.crops, function(i, c) {
        if (c.crop == settings.crop) {
          crop = c;
          return;
        }
      });

      var numeric_crop_ratio = settings.format != 'none' ? numericAspectRatio() : current_image_width / current_image_height;

      if (crop) {
        current_crop_points = {
          x1: crop.x,
          y1: crop.y,
          x2: crop.x + crop.w,
          y2: Math.round(crop.y + (crop.w * numeric_crop_ratio))
        };
      } else {
        var width = data.image.width;
        var height = Math.round(width * numeric_crop_ratio);
        if (height > data.image.height) {
          height = data.image.height;
          width = Math.round(height / numeric_crop_ratio);
        }
        current_crop_points = {
          x1: 0,
          y1: 0,
          x2: width,
          y2: height
        };
      }

      showCropButton();
    };

    var downloadImageMetadata = function() {
      var url = '/imaginable/images/' + current_image_uuid + '.json?token=' + current_image_token + '&callback=?';
      $.getJSON(url, onDownloadImageMetadataComplete);
    };

    var onUploaderFilesAdded = function(up, files) {
      $.each(files, function(i, file) {
      file_list_elem.append(
        '<div id="' + file.id + '">' +
        file.name + ' (' + plupload.formatSize(file.size) + ') <b></b>' +
      '</div>');
     });

     up.refresh(); // Reposition Flash/Silverlight

     if (settings.auto_start == true) up.start();
    };

    var onUploaderFilesRemoved = function(up, files) {
      $.each(files, function(i, file) {
      $('#' + file.id).remove();
     });

     up.refresh(); // Reposition Flash/Silverlight
    };

    var onUploaderUploadProgress = function(up, file) {
      $('#' + file.id + " b").html(file.percent + "%");
    };

    var onUploaderError = function(up, err) {
      file_list_elem.append("<div>Error: " + err.code +
      ", Message: " + err.message +
      (err.file ? ", File: " + err.file.name : "") +
      "</div>"
     );

     up.refresh(); // Reposition Flash/Silverlight
    };

    var onUploaderFileUploaded = function(up, file, response) {
     $('#' + file.id + " b").html("Done");
   	 var responseData = jQuery.parseJSON(response.response);
   	 current_image_uuid = responseData.image.uuid;
   	 current_image_token = responseData.image.token;
   	 current_image_width = responseData.image.width;
   	 current_image_height = responseData.image.height;
   	 resetCropPoints();
   	 existing_image = false;
    };

    var onUploaderUploadComplete = function(up, files) {
      writeToFormFields();
      obj.refreshPreviewImage();
      obj.refreshCroppingPreviewImage();
      showCropButton();
      up.splice();
    };

    var onCancelCropButtonClick = function(event) {
      event.preventDefault();
      $.fancybox.close();
    };

    var onSaveCropButtonClick = function(event) {
      event.preventDefault();
      obj.saveCropping();
    }

    var onAreaSelectorSelectEnd = function(img, selection) {
      selection = cropper.getSelection(false);

      current_crop_points['x1'] = selection['x1'];
      current_crop_points['y1'] = selection['y1'];
      current_crop_points['x2'] = selection['x2'];
      current_crop_points['y2'] = selection['y2'];
      current_crop_points['width'] = selection['width'];
      current_crop_points['height'] = selection['height'];
    };

    var onCroppingSaved = function(response) {
      changeImageVersion(response.new_version);
      obj.refreshPreviewImage();
      $.fancybox.close();
    };

    // Get it all rolling
    initialize();
  };

  $.fn.imaginable = function(options) {
    return this.each(function() {
      var element = $(this);

      // Return early if this element already has a plugin instance
      if (element.data('imaginable')) return;

      var imaginable = new Imaginable(this, options);

      // Store plugin object in this element's data
      element.data('imaginable', imaginable);
    });
  };

})(jQuery);

$(function() {

  $('.imaginable').each(function(){
    var el = $(this);
    el.imaginable();
  });

});
