/*
=============
What is this?
=============

This code, when invoked, will:

- Reveal all hidden fields,
- Unlock all disabled fields,
- Convert all option, radio, and checkbox fields to editable text,
- Remove onchange handlers used to validate entries,
- Add buttons to submit the form without onsubmit handlers,
- Remove field length limits.

It's meant to assist with manual penetration testing of web applications,
as a more convenient alternative to proxies, plugins such as TamperData,
DOM Inspector, etc.
*/

function __U(o) {

  for (var i = 0; i < o.childNodes.length; i++) {

    var c = o.childNodes[i];
    var n = c.nodeName.toLowerCase();

    if (c.childNodes.length) __U(c);

    if (n != 'input' && n != 'option' && n != 'select' && n != 'textarea') continue;

    if (n == 'option') {
      c.parentNode.removeChild(c);
      continue;
    }

    c.disabled   = false;
    c.onchange   = undefined;
    c.onkeypress = undefined;

    if (n == 'input' && !c.__T) {
      var p = c.type;

      if (p != 'file' && p != 'submit' && p != 'reset' && p != 'button') {

        c.type = 'text';

        if (p == 'hidden') {
           var x = document.createTextNode(' {Hidden: ' + c.name + '} ');
           c.parentNode.insertBefore(x, c);
           c.__T = true;
        } else c.value = '{' + p + '}';


      }

      c.maxLength = 1e8;

      if (c.type == 'submit' && !c.__T && c.form.onsubmit) {
        var x = document.createElement('input');
        x.type      = 'button';
        x.value     = '{' + c.value + ' w/o onsubmit()}';
        x.setAttribute('onClick', 'this.form.onsubmit = undefined; this.form.submit()');
        c.__T = true;
        c.parentNode.insertBefore(x, c);
      }

      continue;
    }

    if (n == 'select') {
      var x = document.createElement('input');
      x.type = 'text';
      x.value = '{select}';
      x.id = c.id;
      x.name = c.name;
      c.parentNode.insertBefore(x, c);
      c.parentNode.removeChild(c);
    }

  }
}

__U(document.body);