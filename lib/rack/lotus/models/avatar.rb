class Avatar
  include MongoMapper::Document
  plugin  AttachIt

  belongs_to :author

  has_attachment :image, { :storage => 'gridfs',
                           :styles => { :small  => '48x48',
                                        :medium => '150x150>' }}

  validates_attachment_presence :image
end
