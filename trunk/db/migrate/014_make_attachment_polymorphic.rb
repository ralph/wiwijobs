class MakeAttachmentPolymorphic < ActiveRecord::Migration
  def self.up
    add_column :attachments, :attachable_id, :integer
    add_column :attachments, :attachable_type, :string
    remove_column :attachments, :owner_id
  end

  def self.down
    remove_column :attachments, :attachable_id
    remove_column :attachments, :attachable_type
    add_column :attachments, :owner_id, :integer
  end
end
