module Admin::Terryblr::PagesHelper

  def page_field(page)
    content_tag(:span, (page.children.empty? ? '&nbsp;' : link_to("", admin_pages_path(:parent_id => page.id, :format => "js"), :remote => true, :method => :get)), :class => 'collapsed', :style => "margin-left:#{page.parents.size*17}px") +
    link_to(image_tag('admin/page_icon.png', :class => "page_icon")+page.title, edit_admin_page_path(page))
  end

  def state_field(page)
    page.state.titleize
  end

  def add_child_link(page)
    link_to 'Add Child', new_admin_page_path(:parent_id => page.id)
  end

end
