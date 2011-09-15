class TestController < ApplicationController
  def index
    @items = [
      { name: 'Mr Bar', title: 'Gardener' },
      { name: 'Mr Bazzle', title: 'Landscaper' },
    ]
  end
end