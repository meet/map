document.observe('dom:loaded', function() {
  new Ajax.Request('/google_groups/' + $('shown').readAttribute('data-id') + '.json', {
    method: 'get',
    onSuccess: function(response) {
      $$('table tr:first-child').each(function (row) {
        row.insert(new Element('th').update(new Element('img', { src: '/images/google/apps-32.png' })));
      });
      response.responseJSON.members.each(function (mem) {
        console.log(mem);
        var rows = $$('tr[data-mail="' + mem.mail + '"]');
        if (rows.length) {
          rows[0].writeAttribute('data-mail', null);
          rows[0].insert(new Element('td').update(new Element('img', { src: '/images/glyphish/117-todo.png' })));
        } else {
          $$('table')[0].insert(new Element('tr')
            .insert(new Element('td'))
            .insert(new Element('td').insert(new Element('tt').update(mem.name)))
            .insert(new Element('td').update(new Element('img', { src: '/images/glyphish/117-todo-surprise.png' })))
          );
        }
      });
      $$('tr[data-mail]').each(function (row) {
        row.insert(new Element('td').update(new Element('img', { src: '/images/glyphish/117-todo-empty.png' })));
      });
    }
  });
});
