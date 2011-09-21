class Views::Test < Weld::View
  def index
    { item: @items }
  end

  def index_config
    {
      # map: proc
      alias: { position: 'title' },
    }
  end
end