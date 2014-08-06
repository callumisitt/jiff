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
});