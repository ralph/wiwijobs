class CreateAttachments < ActiveRecord::Migration
  def self.up
    create_table :attachments do |t|
      t.column :owner_id, :integer
      t.column :type, :string
      t.column :content_type, :string
      t.column :filename, :string
      t.column :size, :integer
      t.column :width, :integer
      t.column :height, :integer
      t.column :parent_id, :integer
    end
  end

  def self.down
    drop_table :attachments
  end
end
