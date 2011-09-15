class Views::Test < Weld::View
  def index
    { item: @items }
  end

  def index_config
    {
      alias: { position: 'title' }
    }
  end
end