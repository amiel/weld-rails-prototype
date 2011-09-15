class Views::Test < Weld::View
  def index
    { item: @items }
  end
end