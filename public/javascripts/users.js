document.observe('dom:loaded', function() {
  function username() {
    $('username-preview').update($F(this).escapeHTML());
  }
  $('directory_new_user_username').on('change', username);
  $('directory_new_user_username').on('keyup', username);
});
