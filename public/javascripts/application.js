document.observe('dom:loaded', function() {
  // Border rotates past content when content is very tall
  if ($('content') && $('content').getHeight() > 3000) {
    $('border').setStyle({
      '-webkit-transform': 'none',
      'MozTransform': 'none', // Prototype ticket #970
      'transform': 'none'
    });
  }
  
  // Old browsers don't show input placeholder text
  function supports_input_placeholder() {
    var i = document.createElement('input');
    return 'placeholder' in i;
  }
  if ( ! supports_input_placeholder()) {
    var width = 0;
    $$('label.fallback').each(function(elt) {
      elt.setStyle({ display: 'inline-block' });
      width = Math.max(width, elt.getWidth());
    });
    $$('label.fallback').each(function(elt) {
      elt.setStyle({ width: width+'px' });
    });
  }
});
