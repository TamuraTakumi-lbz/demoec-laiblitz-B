module ItemsHelper
  def item_sold?(item)
    Purchase.exists?(item_id: item.id)
  end
end
