function submit_form(caller, form, server, hideSpinner) {
  hideSpinner ? null : $('.spinner.small').css('display', 'inline-block');
	form.find('textarea.output').val('');
  
  form.bind('ajax:complete', function() { 
    $('.spinner.small').hide();
  });
	
	if (caller.data('sudo')) {
 		handle_sudo(caller, form, server);
	} else {
	 form.submit();
	} 
}

function handle_sudo(caller, form, server) {
  if (sessionStorage.getItem('sudo-' + server)) {
    form.find('input.password').val(sessionStorage.getItem('sudo-' + server));
    form.submit();
  } else {
  	set_sudo(server);
  }
}

function set_sudo(server) {
  if (sessionStorage.getItem('sudo-' + server)) {
    $('#sudo .password').hide().val(sessionStorage.getItem('sudo-' + server));
    $('#sudo .button').val('Allow Sudo Access');
  }
  $('#sudo').foundation('reveal', 'open');
}

function submit_sudo(server) {
	$('#message').empty();
	$('#sudo').foundation('reveal', 'close');
  
  sessionStorage.setItem('sudo-' + server, $('#sudo form').find('input.password').val());
  $('#sudo form').submit();
}

function output_response(response, outputType) {
  switch (outputType) {
    case 'textarea':
      var output = $('textarea.output');
      output.val(output.val() + response);
      output.scrollTop(output[0].scrollHeight - output.height());
      break;
    case 'package-replace':
      var parsePackage = /Inst(.[^\]]*)/;
      response = parsePackage.exec(response);
      if (response) {
        response = response[1].trim().split(' ')[0].replace('.', '');
        $('*[data-package=' + response + ']').addClass('success');
      }
      break;
  }
}

function stream(server, outputType) {
  outputType = outputType || 'textarea';
  var source = new EventSource('/server/' + server + '/output');
  
	source.addEventListener('heartbeat', function(e) { return e; });
  source.addEventListener('server_' + server + '.output', function(e) {
  	var response = $.parseJSON(e.data);
		
		if(response == '%END%') {
      $('.spinner.small').hide();
		} else {
      output_response(response, outputType);
    }
  });
	$(window).bind('beforeunload', function(){
	  source.close();
	});
}

$(document).ready(function() {
	var server = $('body').data('server');
	
  // get output for textarea
	if ( $(".ajax.output").length > 0 ) {
		submit_form($(".ajax.output"), $(".ajax.output").closest('form'), server, true);
	}

  // submut command events
  $(document).on('click', '*[data-submit]', function(e) {
  	submit_form($(this), $(this).closest('form'), server);
		$('#actions-drop-' + server).foundation('dropdown', 'close', $('#actions-drop-' + server));
  });

  // submit toggle/dropdown events
  $('*[data-option-submit]').change(function() {
    submit_form($(this), $(this).closest('form'), server, $(this).data('hide-spinner'));
  });
  
  // set codemirror for config file editing
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
  
  // automatically scroll to end of textarea
  $("textarea").each(function() {
    $(this).scrollTop($(this)[0].scrollHeight);
  });
  
  // ask for sudo password on restricted pages
  if ($('#sudo').data('hidden') !== true) set_sudo(server);
	
  $(document).on('opened', '[data-reveal]', function () {
	  $("[id$=password]").first().focus();
	});
  
  // handle sudo password submission
  $('#sudo form').submit(function() { submit_sudo(server); });
	  
  // stream output from server
  if (server != null && $('textarea.output').length) {
		stream(server);
	}
});