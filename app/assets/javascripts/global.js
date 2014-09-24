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
	var server = $('body').data('server');
	
	if ( $(".ajax.output").length > 0 ) {
		submit_form($(".ajax.output"), $(".ajax.output").closest('form'));
	}

  $(document).on('click', '*[data-submit]', function(e) {
  	submit_form($(this), $(this).closest('form'));
		$('#actions-drop-' + server).foundation('dropdown', 'close', $('#actions-drop-' + server));
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
  
  // load server item without blocking page load
  $('.server-item').each(function() {
    var item = $(this);

    $.get("/server/" + item.data('server'), function(data) {
      item.css('text-align', 'left');
      item.hide().html(data).fadeIn('fast');
    }, "html");
  });
  
  $("textarea").each(function() {
    $(this).scrollTop($(this)[0].scrollHeight);
  });
  
  $('.sudo').foundation('reveal', 'open');
	$(document).on('opened', '[data-reveal]', function () {
	  $("[id$=password]").first().focus();
	});
  
  // stream output from server
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