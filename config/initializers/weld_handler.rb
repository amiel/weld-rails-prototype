# A namespace for views
module Views
end

module Weld
  class View
    attr_reader :controller

    def initialize(controller, assigns)
      @controller = controller
      assigns.each do |name, value|
        instance_variable_set "@#{ name }", value
      end
    end
  end
end


module Weld
  module Compiler
    def self.context
      ExecJS.compile <<-JAVASCRIPT
        var run = function(html, data) {
          var jsdom = require('jsdom');
          var weldlib = require('weld');

          var a;
          jsdom.env(html, function(error, window) {
            var element = window.document;
            weldlib.weld(element, data);
            a = element.innerHTML;
          });
          return a;
        };
      JAVASCRIPT
    end
  end
end

module ActionView
  module Template::Handlers
    class Weld
      # Default format used by Weld.
      class_attribute :default_format
      self.default_format = Mime::HTML

      def self.call(template)
        <<-RUBY
          # raise self.controller.inspect
          # raise @virtual_path.inspect
          # raise self.assigns.inspect
          # HACK:

          begin
            load(Rails.root.join('app/views', @virtual_path + ".rb"))
            class_name = self.controller.class.to_s.gsub(/Controller$/, '')
            view = Views.const_get(class_name)
            data = view.new(self.controller, self.assigns).send self.controller.action_name
          rescue LoadError # , NameError
            # Fall back to assigns
            data = @data
          end

          Weld::Compiler.context.call('run', %q{#{ template.source }}, data)
        RUBY
      end

    end
  end
end

ActionView::Template.register_template_handler(:weld, ActionView::Template::Handlers::Weld)

