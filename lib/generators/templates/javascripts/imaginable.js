(function($){

  var Imaginable = function(element, options) {
    // CONSTRANTS
    var ASPECT_RATIOS = {square: '1:1', tv: '3:2', wide: '5:2', portrait: '13:20'}
    var ASPECT_RATIO_IDS = {original: 0, square: 1, tv: 2, wide: 3, portrait: 4}

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
    var version_field;

    // SETTINGS
    var settings = $.extend({
      prefix:              main_elem.data('imaginable-prefix'),
      scaleServer:         main_elem.data('imaginable-scale-server')     || 'http://127.0.0.1:3333',
      uploadServer:        main_elem.data('imaginable-upload-server')    || 'http://127.0.0.1:3001',
      preview_width:       main_elem.data('imaginable-preview-width')    || 250,
      enable_cropping:     main_elem.data('imaginable-enable-cropping')  || true,
      force_crop:          main_elem.data('imaginable-force-crop')       || false,
      format:              main_elem.data('imaginable-format')           || 'original',
      new_version:         main_elem.data('imaginable-new-version') + '' || '0',

      force_crop:          main_elem.data('imaginable-force-crop')       || false,

      runtimes:            'flash',
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
    var existing_image = false;
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
    this.refreshPreviewImage = function() {
      var preview_url = settings.scaleServer + '/image/' + current_image_uuid + '-' + image_version + '-' + settings.format + '-' + settings.preview_width + '.jpg';

      preview_image_elem.attr('src', preview_url).load(function() {
        preview_image_elem.fadeIn();
        uploader.refresh();
      });
    }

    this.refreshCroppingPreviewImage = function() {
      var crop_preview_url = settings.scaleServer + '/image/' + current_image_uuid + '-' + image_version + '-original-600-600.jpg';

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

          if (settings.format != 'original')
            cropper.setOptions({aspectRatio: ASPECT_RATIOS[settings.format]});

          cropper.setSelection(crop_points['x1'],crop_points['y1'],crop_points['x2'],crop_points['y2'],false);
          cropper.setOptions({ show: true });
          cropper.update();
        },
        afterClose: function() {
          var img_elm = $('.fancybox-wrap .imaginable_crop_image');
          img_elm.imgAreaSelect({
            remove: true
          });
        }
      });
    };

    this.saveCropping = function() {
      var crop_points = getCropPoints();

      var prefix = 'crop' + ASPECT_RATIO_IDS[settings.format] + '_';
      var x = crop_points['x1'];
      var y = crop_points['y1'];
      var width = crop_points['width'];
      var image_data = {};
      image_data[prefix + 'x'] = x
      image_data[prefix + 'y'] = y
      image_data[prefix + 'width'] = width;
      var data = {_method: 'PUT', image: image_data, callback: '?', auth_token: current_image_token};

      var url = settings.uploadServer + '/images/' + current_image_uuid;

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
      initializeImageVersion();
      initializeButtons();
      initializeUploader();
      initializeCropper();
    };

    var initializeElements = function() {
      // Form Fields
      uuid_field = $('#' + settings.prefix + '_uuid');
      token_field = $('#' + settings.prefix + '_token');
      version_field = $('#' + settings.prefix + '_version');

      if (uuid_field.val() != null && uuid_field.val() != "") {
        existing_image = true;
        current_image_uuid = uuid_field.val();
        current_image_token = token_field.val();
        downloadImageMetadata();
      }

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

    var initializeImageVersion = function() {
      image_version = settings.new_version.replace(/'/, "").replace(/'/, "");

      form_value = version_field.val();
      if (form_value != null && form_value.length > 0)
        obj.refreshPreviewImage();

      //form_value = version_field.val();
      //
      //if (form_value != null && form_value.length > 0) {
      //  image_version = form_value;
      //} else {
      //  image_version = settings.new_version;
      //}
    };

    var initializeButtons = function() {
      // Cropper
      $('.imaginable_save_crop_button').live('click', onSaveCropButtonClick);
      $('.imaginable_cancel_crop_button').live('click', onCancelCropButtonClick);
    };

    var initializeUploader = function() {
      uploader = new plupload.Uploader({
        runtimes:             settings['runtimes'],
        browse_button:        uploader_elem.attr('id'),
        container:            uploader_elem.parent().first().attr('id'),
        max_file_size:        settings['max_file_size'],
        url:                  settings['uploadServer'] + '/images',
        file_data_name:       settings['file_data_name'],
        multipart:            settings['multipart'],
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

      if (settings.format != 'original') {
        var numeric_aspect_ratio = numericAspectRatio();
        if (numeric_aspect_ratio > 1) {
          // Width > Height
          current_crop_points['x2'] = current_image_width;
          current_crop_points['y2'] = Math.round(current_image_width * numeric_aspect_ratio);
          current_crop_points['height'] = current_crop_points['y2'];
        } else {
          // Width < Height || Width == Height
          current_crop_points['y2'] = current_image_height;
          current_crop_points['x2'] = Math.round(current_image_height * numeric_aspect_ratio);
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
      var format = settings.format;

      if (format != 'original') {
        var aspect_ratio = ASPECT_RATIOS[format];
        return (d = (aspect_ratio || '').split(/:/))[0] / d[1];
      } else {
        return 0;
      }
    };

    var writeToFormFields = function() {
      uuid_field.val(current_image_uuid);
      token_field.val(current_image_token);
      version_field.val(image_version);
    };

    var downloadImageMetadata = function() {
      var url = settings.uploadServer + '/images/' + current_image_uuid + '?callback=?';
      $.getJSON(url, onDownloadImageMetadataComplete);
    };

    var onDownloadImageMetadataComplete = function(data) {
      current_image_width = data.image.width;
      current_image_height = data.image.height;

      // Make sure that crop points are initialized
      getCropPoints();

      var prefix = 'crop' + ASPECT_RATIO_IDS[settings.format] + '_';

      current_crop_points.x1 = parseInt(data.image[prefix + 'x']);
      current_crop_points.y1 = parseInt(data.image[prefix + 'y']);
      current_crop_points.width = parseInt(data.image[prefix + 'width']);
      current_crop_points.x2 = current_crop_points.x1 + current_crop_points.width;

      var numeric_aspect_ratio = settings.format != 'original' ? numericAspectRatio() : current_image_width / current_image_height

      current_crop_points.height = Math.round(parseFloat(current_crop_points.width) / numeric_aspect_ratio);
      current_crop_points.y2 = current_crop_points.y1 + current_crop_points.height;

      showCropButton();
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
   	 responseData = jQuery.parseJSON(response.response);
   	 current_image_uuid = responseData.image.uuid;
   	 current_image_token = responseData.auth_token;
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
