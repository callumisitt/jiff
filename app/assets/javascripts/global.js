$(document).ready(function() {
  $('*[data-submit]').click(function() {
    $(this).closest("form").submit();
  });
});