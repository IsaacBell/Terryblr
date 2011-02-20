module Admin::Terryblr::ProductsHelper
  
  def image_field(product)
    !product.photos.empty? ? image_tag(product.photos.first.image.url(:thumb)) : ""
  end
  
  def product_field(product)
    link_to product.title, edit_admin_product_path(product)
  end
  
  def inventory_field(product)
    content_tag(:table) do
      content_tag(:thead) do
        content_tag(:th, "Size") +
        content_tag(:th, "Qty")
      end +
      content_tag(:tbody) do
        product.sizes.map do |s|
          content_tag(:tr) do
            content_tag(:td, s.name) +
            content_tag(:td, s.qty)
          end
        end.join
      end
    end
  end
  
  def total_field(product)
    product.sizes.sum(:qty)
  end
  
  def sales_field(product)
    Money.new(product.orders.sum(:final_amount_cents)).format
  end
  
end
