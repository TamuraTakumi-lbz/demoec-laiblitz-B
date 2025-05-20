module ItemsHelper
  def action_button(label, path, options = {}, item:)
    if item_sold?(item)
      link_to label, '#', class: "#{options[:class]} disabled-button", disabled: true
    else
      link_to label, path, options
    end
  end

  def item_sold?(item)
    PurchaseItem.exists?(item_id: item.id)
    # false
  end
end
