class CreateSites < ActiveRecord::Migration
  
  TABLES = %w(posts pages features).freeze
  
  def self.up
    create_table :sites, :force => true do |t|
      t.string :name
      t.string :lang
      t.timestamps
    end
    add_index :sites, :name, :unique => true

    TABLES.each do |tbl|
      add_column tbl, :site_id, :integer
      add_index tbl, :site_id
    end
    
    # Migrate existing posts to new site
    s = Terryblr::Site.find_by_name('www') || Terryblr::Site.create(:name => 'www')
    TABLES.each do |tbl|
      "Terryblr::#{tbl.classify}".constantize.update_all({:site_id => s.id}, {:site_id => nil})
    end
    
  end

  def self.down

    drop_table :sites

    TABLES.each do |tbl|
      remove_column tbl, :site_id
    end

  end
end