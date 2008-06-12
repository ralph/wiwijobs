class Avatar < ActiveRecord::Base
  belongs_to :user
  # also possible to resize all uploaded pictures to a specific format: :resize_to => [640,480]
  has_attachment :content_type => :image,
                 :storage => :file_system,
                 :max_size => 500.kilobytes,
                 :thumbnails => { :thumb => '150x180' }
  validates_as_attachment
end
