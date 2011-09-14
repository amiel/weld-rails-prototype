class TestController < ApplicationController
  def index

    context = ExecJS.compile <<-JAVASCRIPT
      var run = function(html, data) {
        var jsdom = require('jsdom');
        var weld = require('weld');

        var a = "";

        jsdom.env(html, function(error, window) {
          var element = window.document.getElementById('container');
          window.document.a = "weld: ";
          var w = weld.weld(element, data);
          a = element.innerHTML;
//          a += "t: " + element.textContent;
//          a += "<br/>";
//          a += "h: <pre>" + htmlEntities(element.innerHTML) + "</pre>";
//          a += "h2: <pre>" + htmlEntities(w.innerHTML) + "</pre>";
//          a += "<br/><br/>";
//          a += "<pre>" + window.document.a + "</pre>";
        });
        return a;
      };
    JAVASCRIPT

    html = <<-HTML
      <div>
        <ol id="container">
          <li class="item">
            <span class="name">Mr Foo</span>
            <span class="title">Groundskeeper</span>
          </li>
        </ol>
      </div>
    HTML

    data = { item: [
      { name: 'Mr Bar', title: 'Gardener' },
      { name: 'Mr Bazzle', title: 'Landscaper' },
    ] }

    render text: context.call('run', html, data)
  end
end