/*
 * Terryblr - Public Behaviours
 *
 * Lachlan Laycock @ Jackson Laycock
 * 04 March 2010
 *
 */

  function remove_duplicate_month(month) {
    $(document).ready(function () {
      tm = $("." + month);
      if (tm.length == 2) {
        tm.last().remove();
      };
    });
  }

 $(document).ready(function() {

   // Add browser classes to allow for targeting
   $('body').addClass($.uaMatch(navigator.userAgent).browser)
   $('body').addClass('v'+$.browser.version.substr(0,3).replace(/\./,'-'))
   mobile = navigator.userAgent.match(/iPad|iPod|iPhone|Android/i)
   if (mobile) {
     $('body').addClass('mobile')
     $('body').addClass(mobile)
   }

  // Add loading class to all links when clicked on - use CSS to style
  $('a').click(function(e) {
    $(this).addClass('loading')
  })
  // Remove loading class to all links when AJAX finished - use CSS to style
  $('a').ajaxComplete(function(e) {
    $(this).removeClass('loading');
  })

  var gallerias = $('.galleria')
  if (gallerias.length) {
    Galleria.loadTheme("/javascripts/galleria/src/themes/classic/galleria.classic.js");
    gallerias.galleria({
      extend: function(options) {
        // listen to when an image is shown
        this.bind(Galleria.IMAGE, function(e) {
          var currentImage = $(e.imageTarget) // the current image
          
        });
      }
    })
  }

   // Auto-hide fields
   auto_hides = $('.auto-hide-text input[type=text]')
   if (auto_hides.length > 0) {
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
   
   // Share It Box
   $('a.share').mouseenter(function() {		

   	//get the height, top and calculate the left value for the sharebox
   	var height = $(this).height() + 0;

   	//get the left and find the center value
   	var top = $(this).offset().top;
   	var left = $(this).offset().left + ($(this).width() /2) - ($('#shareit-box').width() / 2);		

   	//assign the value to variables and encode it to url friendly
   	var field = $(this).attr('href');
   	var url = encodeURIComponent(field);
   	var title = encodeURIComponent($(this).attr('title'));

   	//assign the height for the header, so that the link is cover
   	$('#shareit-header').height(height);

   	//set the position, the box should appear under the link and centered
   	$('#shareit-box').css({'top':top, 'left':left});

   	//Setup the bookmark media url and title
   	$('a[rel=shareit-email]').attr('href', 'mailto:?subject=' + title + '&body=' + url);
   	$('a[rel=shareit-facebook]').attr('href', 'http://www.facebook.com/share.php?u=' + url + '&t=' + title);
   	$('a[rel=shareit-delicious]').attr('href', 'http://del.icio.us/post?v=4&noui&jump=close&url=' + url + '&title=' + title);
   	$('a[rel=shareit-designfloat]').attr('href', 'http://www.designfloat.com/submit.php?url='  + url + '&title=' + title);
   	$('a[rel=shareit-digg]').attr('href', 'http://digg.com/submit?phase=2&url=' + url + '&title=' + title);
   	$('a[rel=shareit-stumbleupon]').attr('href', 'http://www.stumbleupon.com/submit?url=' + url + '&title=' + title);
   	$('a[rel=shareit-twitter]').attr('href', 'http://twitter.com/home?status=' + title + ':%20' + url);
   	$('a[rel=shareit-tumblr]').attr('href', 'http://tumblr.com/share?v=2&u='+ url +'&t=' + title);

   	//display the box
   	$('#shareit-box').show();

   });

   //onmouse out hide the shareit box
   $('#shareit-box').mouseleave(function () {
   	$('#shareit-field').val('');
   	$(this).hide();
   });

   //hightlight the textfield on click event
   $('#shareit-field').click(function () {
   	$(this).select();
   });

})