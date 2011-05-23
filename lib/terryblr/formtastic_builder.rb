#
# Custom Formtastic form builder class. 
# Contains custom helper methods used in forms.
#
class TerryblrBuilder < Formtastic::SemanticFormBuilder 

  # Creates an input field that appears as an blank underlined space.
  # @param [Method] the method of the form's object to be used for the input field
  # @param [Options, hash] a hash of options provided to the input field
  def underline_input(method, options)
    type = :string
    form_helper_method = :text_field

    html_options = options.delete(:input_html) || {}
    html_options = default_string_options(method, type).merge(html_options) if [:numeric, :string, :password, :text].include?(type)

    self.label(method, options_for_label(options)) <<
    "<span>#{options[:prefix]}</span>".html_safe <<
    self.send(form_helper_method, method, html_options)
  end
  
  # Creates an file upload field.
  # @param [Method] the method of the form's object to be used for the input field
  # @param [Options, hash] a hash of options provided to the input field
  def files_input(method, options)
    type = :string
    form_helper_method = :file_field

    html_options = options.delete(:input_html) || {}
    html_options = default_string_options(method, type).merge(html_options) if [:numeric, :string, :password, :text].include?(type)

    self.label(method, options_for_label(options)) <<
    self.send(form_helper_method, method, html_options)
  end
  
  # Creates an input field for price attributes.
  # @param [Method] the method of the form's object to be used for the input field
  # @param [Options, hash] a hash of options provided to the input field
  def price_input(method, options)
    type = :string
    form_helper_method = :text_field

    html_options = options.delete(:input_html) || {}
    html_options = default_string_options(method, type).merge(html_options) if [:numeric, :string, :password, :text].include?(type)

    self.label(method, options_for_label(options)) <<
    "<span>$</span>".html_safe <<
    self.send(form_helper_method, method, html_options)
  end
  
end

