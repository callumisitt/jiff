function submit_form(caller, form) {
	$('.spinner.small').css('display', 'inline-block');
	form.find('textarea.output').val('');
	
	var id;
	if (id = caller.attr('data-sudo')) {
 		$('#sudo-hidden').foundation('reveal', 'open');
		$('.sudo-form').submit(function(sudo_form) {
			sudo_form.preventDefault();
			var pwd = $(this).find('input.password').val();
			$('#sudo-hidden').foundation('reveal', 'close');
			form.find('input.password').val(pwd);
			
			$('#message').empty();
			$(this).unbind('submit'); // prevents submitting multiple times on error
			form.submit();
		});
	} else {
	 form.submit();
	}
}

$(document).ready(function() {
	if ( $(".ajax.output").length > 0 ) {
		submit_form($(".ajax.output"), $(".ajax.output").closest('form'));
	}

  $('*[data-submit]').click(function(e) {
  	submit_form($(this), $(this).closest('form'));
  });

  $('*[data-option-submit]').change(function() {
    submit_form($(this), $(this).closest('form'));
  });
  
  $("textarea[data-codemirror]").each(function() {
    CodeMirror.fromTextArea($(this).get(0), {
      lineNumbers: true,
      mode: 'text/x-sh'
    });
  });
  
  // load server/site item without blocking page load
  $('[class$=-item]').each(function() {
    var item = $(this);
    var type = item.data('server') ? 'server' : 'site';

    $.get("/" + type + "/" + item.data(type) + "/view-type/" + item.data('view-type'), function(data) {
      item.css('text-align', 'left');
      item.hide().html(data).fadeIn('fast');
    }, "html");
  });
  
  $("textarea").each(function() {
    $(this).scrollTop($(this)[0].scrollHeight);
  });
  
  $('.sudo').foundation('reveal', 'open');
  
  // stream output from server
  var server = $('body').data('server');
  if (server != null && $('textarea.output').length) {
    var source = new EventSource('/server/' + server + '/output');
		source.addEventListener('heartbeat', function(e) { return e; });
    source.addEventListener('server_' + server + '.output', function(e) {
    	var response = $.parseJSON(e.data);
      var output = $('textarea.output');
			
			if(response == '%END%') {
				$('.spinner.small').hide();
			} else {
	      output.val(output.val() + response);
	      output.scrollTop(output[0].scrollHeight - output.height());
			}
    });
		$(window).bind('beforeunload', function(){
		  source.close();
		});
  }
  
});