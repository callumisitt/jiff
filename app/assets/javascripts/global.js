$(document).ready(function() {
  // submit forms with required data attr
  $('*[data-submit]').click(function() {
    $(this).closest("form").submit();
  });
  
  // use CodeMirror for specified textareas
  $("textarea[data-codemirror]").each(function() {
    CodeMirror.fromTextArea($(this).get(0), {
      lineNumbers: true,
      mode: "text/x-sh"
    });
  });
  
  $("textarea").each(function() {
    $(this).scrollTop($(this)[0].scrollHeight);
  });
  
  // stream output from server
  var server = $('body').data('server');
  if (server != null) {
    var source = new EventSource('/server/' + server + '/output');
    source.addEventListener('server.output', function(e) {
    	var response = $.parseJSON(e.data);
      var output = $('#site_output');
      output.val(output.val() + response);
      output.scrollTop(output[0].scrollHeight - output.height());
    });
  }
  
});