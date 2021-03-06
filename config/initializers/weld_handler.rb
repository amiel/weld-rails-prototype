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
        var run = function(html, data, config) {
          var jsdom = require('jsdom');
          var weldlib = require('weld');

          var a;
          jsdom.env(html, function(error, window) {
            var element = window.document;
            weldlib.weld(element, data, config);
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
            view = Views.const_get(class_name).new(self.controller, self.assigns)
            data = view.send self.controller.action_name
            config_method = self.controller.action_name + "_config"
            config = view.send config_method if view.respond_to? config_method
          rescue LoadError # , NameError
            # Fall back to assigns
            data = @data
          end

          Weld::Compiler.context.call('run', %q{#{ template.source }}, data, config || {})
        RUBY
      end

    end
  end
end

ActionView::Template.register_template_handler(:weld, ActionView::Template::Handlers::Weld)

