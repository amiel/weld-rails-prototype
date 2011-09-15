class TestController < ApplicationController
  def index
    @items = [
      { name: 'Mr Bar', position: 'Gardener' },
      { name: 'Mr Bazzle', position: 'Landscaper' },
    ]
  end
end