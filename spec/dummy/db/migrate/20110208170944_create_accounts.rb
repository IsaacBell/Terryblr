class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.string :uname
      t.string :fake

      t.timestamps
    end
  end

  def self.down
    drop_table :accounts
  end
end
