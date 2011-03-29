$(function() {
  
  $.extend({
    imaginableUploader: function(prefix, upload_server, scale_server, preview_width) {
      var uploader = new plupload.Uploader({
    		runtimes:             'flash',
    		browse_button:        prefix + '_browse_button',
    		container:            prefix + '_container',
    		max_file_size:        '10mb',
    		url:                  upload_server + '/images',
    		file_data_name:       'image_file',
    		multipart:            true,
    		multiple:             false,
    		auto_start:           true,
    		flash_swf_url:        '/javascripts/plupload.flash.swf',
    		silverlight_xap_url:  '/javascripts/plupload.silverlight.xap',
    		filters: [
    			{title: "Image files", extensions: "jpg,gif,png"},
    		]
    	});
    	
    	//alert('YO!');
    	
    	uploader.init();

    	uploader.bind('FilesAdded', function(up, files) {
    	  if (up.files.length == 1 || up.settings.multiple != false) {
    	    $.each(files, function(i, file) {
      			$('#' + prefix + '_file_list').append(
      				'<div id="' + file.id + '">' +
      				file.name + ' (' + plupload.formatSize(file.size) + ') <b></b>' +
      			'</div>');
      		});
    	  } else {
    	    up.splice(0, up.files.length - 1);
    	    var file = files[files.length - 1];
    	    $('#' + prefix + '_file_list').append(
    				'<div id="' + file.id + '">' +
    				file.name + ' (' + plupload.formatSize(file.size) + ') <b></b>' +
    			'</div>');
    	  }

    		up.refresh(); // Reposition Flash/Silverlight

    		if (up.settings.auto_start == true) {
    		  up.start();
    		}
    	});

    	uploader.bind('FilesRemoved', function(up, files) {
    		$.each(files, function(i, file) {
    			$('#' + file.id).remove();
    		});

    		up.refresh(); // Reposition Flash/Silverlight
    	});

    	uploader.bind('UploadProgress', function(up, file) {
    		$('#' + file.id + " b").html(file.percent + "%");
    	});

    	uploader.bind('Error', function(up, err) {
    		$('#' + prefix + '_file_list').append("<div>Error: " + err.code +
    			", Message: " + err.message +
    			(err.file ? ", File: " + err.file.name : "") +
    			"</div>"
    		);

    		up.refresh(); // Reposition Flash/Silverlight
    	});

    	uploader.bind('FileUploaded', function(up, file, response) {
    		$('#' + file.id + " b").html("100%");

    		responseData = jQuery.parseJSON(response.response);

    		$('#' + prefix + '_uuid').val(responseData.image.uuid);
    		$('#' + prefix + '_token').val(responseData.auth_token);
    		$('#' + prefix + '_preview_image').attr('src', scale_server + '/image/' + responseData.image.uuid + '-0-original-' + preview_width + '.jpg').load(function() {  
          uploader.refresh();
        });
    	});

    	uploader.bind('UploadComplete', function(up, files) {
    	  up.splice();
    	});
    }
  });
  
  $('a[data-imaginable-prefix]').each(function(){
    
    var el = $(this);
    var prefix = el.data('imaginable-prefix');
    var upload_server = el.data('imaginable-upload-server');
    var scale_server = el.data('imaginable-scale-server');
    var preview_width = el.data('imaginable-preview-width');
    
    $.imaginableUploader(prefix, upload_server, scale_server, preview_width);
    
  });
  
});