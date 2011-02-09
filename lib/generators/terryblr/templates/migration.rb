class AddIsAdminTo<%= table_name.camelize %> < ActiveRecord::Migration
  def self.up
    add_column :<%= table_name %>, :is_admin, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :<%= table_name %>, :is_admin
  end
end
