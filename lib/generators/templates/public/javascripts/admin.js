/*
 * Terryblr - Admin Behaviours
 *
 * Lachlan Laycock @ Jackson Laycock
 * 22 Feb 2010
 *
 */

jQuery.fn.bindAll = function(options) {
	var $this = this;
	jQuery.each(options, function(key, val){
		$this.bind(key, val);
	});
	return this;
}

$(document).ready(function() {

  // Hide flash messages
  $("#flash").delay(2000).fadeOut('slow');
  
  var links = $('a')
  if (links.length) {
    links.click(function(e) {
      $(this).addClass('loading')
    })

    // Remove loading class to all links when AJAX finished - use CSS to style
    links.ajaxComplete(function(e) {
      $(this).removeClass('loading');
    })

    links.ajaxSuccess(function(e) {
      // Features select post. Eg: /admin/new/feature
      features = $("#feature_post_browser .archives a")
      if (features.length) {
        features.unbind('click')
        features.bind('click', function(e) {
          a = $(e.currentTarget)

          // Set hidden field to assoc post
          dom_id = a.parent().attr('id')
          match = dom_id.match(/\d+/)
          if (match.length) {
            post_id = match[0]
            $("input#feature_post_id").val(post_id)

            // Set title field
            title = a.find('span').html()
            title_field = $("input#feature_title")
            if (title_field.length && title_field.val().length==0) {
              title_field.val(title)
            }

            // Set URL field
            url = "http://"+window.location.host+"/posts/"+post_id+"/"+title.toLowerCase().replace(/\W+/g,'-')
            url_field = $("input#feature_url")
            if (url_field.length && url_field.val().length==0) {
              url_field.val(url)
            }

            // Insert new image
            photo_list = $("#feature_photo_ul")
            if (photo_list.length) {
              img_url = a.css('background-image').match(/http.*\?/)[0]
              img_url = img_url.replace(/thumb/, 'list')
              photo_list.html($("<li>").append($("<img>").attr('src', img_url)))
            }

          }
          // Prevent A link for launching
          return false;
        })
      }
    });

    // Make external links open in new window
    reg = new RegExp("//"+window.location.host+"/");
    links.each(function(i, el) {
      if (!el.href.match(reg)) {
        $(el).attr('target', '_blank')
      }
    })
  }

  // Date pickers
  if ((date_pickers = $(".date-picker input")).length > 0) {
    date_pickers.datepicker();
  }

  // Tag inputs
  if ((tag_textareas = $('.tag-picker textarea')).length > 0) {
    tag_textareas.tags();
  }
  
  // Auto-hide fields
  auto_hides = $('.auto-hide-text input')
  if (auto_hides.length) {
    auto_hides.each(function(i, el) { $(el).attr('default',$(el).val()) })
    auto_hides.focus(function(e) { 
      if ($(this).val()==$(this).attr('default')) $(this).val('')
      $(this).attr('style', 'color:#000');
    })
    auto_hides.blur(function(e) { 
      if ($(this).val().length==0) { 
        $(this).val($(this).attr('default')) 
        $(this).attr('style', '');
      }
    })
  }
  
  // Tiny MCE WYSIWYG editor
  rich_texts = $('.rich-text textarea')
  if (rich_texts.length) {
  	rich_texts.tinymce({
  		// Location of TinyMCE script
  		script_url : '/javascripts/tiny_mce/tiny_mce.js',
  		theme : "advanced",
  		plugins : "pagebreak,style,layer,save,advhr,advimage,advlink,iespell,inlinepopups,insertdatetime,searchreplace,print,contextmenu,paste,directionality,fullscreen,noneditable,visualchars,nonbreaking,template,advlist",
  		theme_advanced_buttons1 : "bold,italic,underline,strikethrough,|,bullist,numlist,|,outdent,indent,|,image,link,unlink,anchor,|,code",
      theme_advanced_buttons2 : "",
      theme_advanced_buttons3 : "",
      theme_advanced_buttons4 : "",
  		theme_advanced_toolbar_location : "top",
  		theme_advanced_toolbar_align : "center",
  		theme_advanced_statusbar_location : false,
  		theme_advanced_resizing : false,
  		content_css : "/stylesheets/tinymce.css",
  	});
  }

	// Post state drop-down
  var state_select_css = '.post-states select, .page-states select, .product-states select'
  var state_input_css = '#post_published_at_input, #page_published_at_input, #product_published_at_input'
  var state_hidden_css = '.post-hidden input, .page-hidden input, .product-hidden input'
  function update_state_select() {
    $(state_input_css).hide()
    $(state_hidden_css).val(this.value)
    switch(this.value) {
      case 'publish_now':
        $(state_select_css).attr('value', "published");
        break;
      case 'published_at':
        $(state_select_css).attr('value', "published");
        $(state_input_css).show();
        break;
      default:
        $(state_select_css).attr('value', this.value);
        break;
    }
  }
  //$(state_select_css).val($(state_hidden_css).val())
  // update_state_select()
	$(state_select_css).change(update_state_select);
  
  // Sizes sortable table
  if ((sizes_list = $('.product-sizes tbody')).length > 0) {
    sizes_list.sortable();
  }
  
  // Photo display types
  var photo_types = $(".photos-display-type input")
  if (photo_types.length) {
    photo_types.click(function() { 
      // Removed selected class from parents then add to selected child input
      $(this).parent().removeClass('selected').children("input:checked").parent().addClass('selected')
    })
  }
  
  // iPhone style checkboxes
  if (typeof($.iphoneStyle)=="function") {
    $('.on-off :checkbox').iphoneStyle()
  }
  
  // Add new size link
  size_tf_lnk = $(".product-sizes tfoot tr a")
  if(size_tf_lnk.length) {
    size_tf_lnk.click(function(e) {
      $('.product-sizes tbody').append($('.product-sizes tbody tr:last-child').clone().show())
      $('.product-sizes tbody tr:last-child input.size_name').val($('.product-sizes tfoot tr input.size_name').val())
      $('.product-sizes tbody tr:last-child input.size_qty').val($('.product-sizes tfoot tr input.size_qty').val())
      $('.product-sizes tfoot tr input').val('')
    })
  }
	
});