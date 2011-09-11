module Weld
  class Loader
    attr_reader :cxt, :modules

    def initialize
      @cxt = V8::Context.new
      @path = [Rails.root.join('js')]
      # @path << @path.first.join('lib')
      @modules = {}
    end

    def log(i, m)
      Rails.logger.debug(("  " * i) + "Weld::Loader: " + m)
    end

    def require(modname, path = @path, i = 0)
      filename = modname.match(/\.js$/) ? modname : "#{ modname }.js"
      log(i, "Looking for: #{ filename.inspect } in #{ path.inspect }")
      # Rails.logger.debug("Weld::Loader: keys: #{ @modules.keys.inspect }")

        filepath = path.collect { |p| p.join(filename) }.find { |f| f.exist? }
        # filepath = path.join filename
        fail LoadError, "non such file: #{ filename } (#{ filepath })" unless filepath

        # @path << filepath.dirname unless @path.include? filepath.dirname
        # Rails.logger.debug("Weld::Loader: PATH: #{ @path.inspect }")

        # modname = filename # filepath.expand_path.to_s

        log(i, "CACHE Loading #{ filepath.inspect }") if @modules[modname]

      unless mod = @modules[modname]
        log(i, "Loading #{ filepath.inspect }")

        load = @cxt.eval("(function(require, module, exports) {#{ File.read(filepath) }})", filepath.expand_path)
        object = @cxt['Object']
        mod = object.new
        mod['exports'] = object.new
        # @cxt[modname] = mod
        @modules[modname] = mod
        load.call(proc {|fn| require(fn, [filepath.dirname] + path, i + 1) }, mod, mod.exports)
      end
      return mod.exports
    end
  end
end

class TestController < ApplicationController
  def index
    @loader = Weld::Loader.new
    domcore = @loader.require('domcore')
    weld = @loader.require('weld')
    n = ""


    c = @loader.cxt
    c['core'] = domcore['core']
    c['weld'] = weld['weld']

    c['htmls'] = <<-HTML
      <div id="foobar">
        <ol>
          <li class="fish">
            HAHAHA
          </li>
        </ol>
      </div>
    HTML

    c.eval <<-JS
      // Stolen from SproutCoreNative
      // (https://github.com/jfahrenkrug/SproutCoreNative/blob/master/SproutCoreNative/SCUIViewController.m)
      this.prototype = core; window = this; window.document = new core.Document(); location = {href: 'http://localhost'}; window.document.prototype = core; window.addEventListener = (new core.Node()).addEventListener; window.navigator = {userAgent: 'Webkit'}; console = {log: function() { gah(); }};


      // Setup some jquery for convenience
      var body = window.document.createElement("body");

      body.innerHTML = htmls;
      var rendered = weld(body, { fish: ['1dude', '2dude', '3dude'] } );

    JS

    # jsdom.env('<div><p class="infos">Here be infos <span class="bar">Baz</span></p></div>', [])
    # weld.weld('foobar')
    # render text: "FOOBAR: #{ c.eval('exports').inspect }"
    render text: "x: #{ c.eval('body') }"
  end
end