class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users, :force => true do |t|
      t.column :login,                     :string
      t.column :email,                     :string
      t.column :crypted_password,          :string, :limit => 40
      t.column :salt,                      :string, :limit => 40
      t.column :created_at,                :datetime
      t.column :updated_at,                :datetime
      t.column :remember_token,            :string
      t.column :remember_token_expires_at, :datetime
      t.column :activation_code, :string, :limit => 40
      t.column :activated_at, :datetime
      t.column :type, :string
      t.column :role_id, :integer
    end
    add_index :users, :login, :unique => true, :name => 'unique_login'
    add_index :users, :email, :unique => true, :name => 'unique_email'
  end

  def self.down
    drop_table :users
  end
end
