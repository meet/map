document.observe('dom:loaded', function() {
  var req;
  
  function search() {
    if (this.getValue().length < 2) {
      req = null;
      $('results').childElements().each(function (elt) {
        elt.remove();
      });
      return;
    }
    
    req = new Ajax.Request('/search', {
      method: 'get',
      parameters: { q: this.getValue() },
      onSuccess: function(response) {
        if (req == response.request) {
          results = $('results')
          users = response.responseJSON.users
          groups = response.responseJSON.groups
          
          results.childElements().each(function (elt) { elt.remove(); });
          
          results.insert(new Element('li', { 'class': 'section' }).insert(
            new Element('img', { src: '/images/glyphish/111-user.png', style: 'padding: 0 2px' })
          ).insert(' '+users.length+' user'+(users.length == 1 ? '' : 's')));
          
          users.each(function (user) {
            results.insert(new Element('li').update(new Element('a', { href: '/users/' + user.username }).update(user.name)));
          });
          
          results.insert(new Element('li', { 'class': 'section' }).insert(
            new Element('img', { src: '/images/glyphish/112-group.png' })
          ).insert(' '+groups.length+' group'+(groups.length == 1 ? '' : 's')));
          
          groups.each(function (group) {
            results.insert(new Element('li').update(new Element('a', { href: '/groups/' + group.groupname }).update(group.name)));
          });
        }
      }
    });
  }
  
  $('search').on('search', search);
  $('search').on('keyup', search);
  
  search.bind($('search'))();
});
