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
    $$('label.fallback').each(function(elt) {
      elt.setStyle({ display: 'inline-block' });
    });
  }
  
  // Fix label widths
  var width = 0;
  $$('label:not(.widelabel)').each(function(elt) {
    if (elt.getStyle('display') != 'none') {
      width = Math.max(width, elt.getWidth());
    }
  });
  $$('label:not(.widelabel)').each(function(elt) {
    elt.setStyle({ width: width+'px' });
  });
  
  // Style labels of disabled inputs
  $$('input[disabled]').each(function(elt) {
    $$('label[for='+elt.id+']').each(function(label) {
      label.addClassName('for_disabled');
    });
  });
});
