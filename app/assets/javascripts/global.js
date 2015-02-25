function submit_form(caller, form, server) {
	$('.spinner.small').css('display', 'inline-block');
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
    form.find('input.password').val(sessionStorage.getItem('sudo'));
    form.submit();
  } else {
  	$('#sudo').foundation('reveal', 'open');
  }
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
	
	if ( $(".ajax.output").length > 0 ) {
		submit_form($(".ajax.output"), $(".ajax.output").closest('form'), server);
	}

  $(document).on('click', '*[data-submit]', function(e) {
  	submit_form($(this), $(this).closest('form'), server);
		$('#actions-drop-' + server).foundation('dropdown', 'close', $('#actions-drop-' + server));
  });

  $('*[data-option-submit]').change(function() {
    submit_form($(this), $(this).closest('form'), server);
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
  
  if ($('#sudo').data('hidden') !== true) $('#sudo').foundation('reveal', 'open');
	
  $(document).on('opened', '[data-reveal]', function () {
	  $("[id$=password]").first().focus();
	});
  
  $('#sudo form').submit(function() {
		$('#message').empty();
		$('#sudo').foundation('reveal', 'close');
	  
    sessionStorage.setItem('sudo-' + server, $(this).find('input.password').val());
	  $(this).submit();
  });
	  
  // stream output from server
  if (server != null && $('textarea.output').length) {
		stream(server);
	}
});