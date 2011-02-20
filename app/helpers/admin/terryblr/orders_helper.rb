module Admin::Terryblr::OrdersHelper
  
  def order_field(order)
    link_to order.number, admin_order_path(order)
  end
  
  def date_field(order)
    order.created_at
  end
  
  def buyer_field(order)
    content_tag(:div, content_tag(:abbr, order.full_name, :title => order.address), :class => "order-name")
  end
  
  def items_field(order)
    order.line_items.map{|li| 
      photo = li.product.photos.first
      link_to(
        image_tag(photo ? photo.image.url(:thumb) : "admin/product.png", :size => "50x50"), admin_product_path(li.product), 
        :title => "#{li.product.title} - #{li.size} x #{li.qty}"
      )
    }.join
  end
  
  def total_field(order)
    order.final_amount.format
  end
  
  
  
end
