class Attachment < ActiveRecord::Base
  has_attachment :storage => :file_system, :max_size => 2.megabytes
  validates_as_attachment
  belongs_to :attachable, :polymorphic => true
  
  def self.delete_all_orphaned
    delete_all(:attachable_id => nil)
  end
end
