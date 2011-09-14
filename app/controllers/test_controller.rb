require_dependency 'weld_compiler'

class TestController < ApplicationController
  def index

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

    render text: WeldCompiler.context.call('run', html, data)
  end
end