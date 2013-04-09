class Avatar
  require 'RMagick'

  include MongoMapper::Document

  # The avatar belongs to a particular Author
  key :author_id, ObjectId
  belongs_to :author, :class_name => 'Author'

  # The array of sizes this avatar has stored.
  key :sizes, Array, :default => []

  # The content type for the image.
  key :content_type

  # Log modification.
  timestamps!

  # Create a new Avatar from the given url
  def self.from_url!(author, url, options = {})
    avatar = Avatar.new(:author_id => author.id,
                        :sizes     => options[:sizes])

    # Pull image down
    response = self.pull_url(url, options[:content_type])

    image = Magick::ImageList.new
    image.from_blob(response.body)

    # Store the content_type
    avatar.content_type = image.mime_type

    # Resize the images to fit the given sizes (crop to the aspect ratio)
    # And store them in the storage backend.
    options[:sizes] ||= []
    images = options[:sizes].each do |size|
      width  = size[0]
      height = size[1]

      # Resize to maintain aspect ratio
      resized = image.resize_to_fill(width, height)
      self.storage_write "avatar_#{avatar.id}_#{width}x#{height}", resized.to_blob
    end

    avatar.save
    avatar
  end

  # Retrieve the avatar image as a byte string.
  def read(size = nil)
    return nil if self.sizes.empty?

    size = self.sizes.first unless size
    Avatar.storage_read "avatar_#{self.id}_#{size[0]}x#{size[1]}"
  end

  # Yield a base64 string encoded with the content type
  def read_base64(size = nil)
    data = self.read(size)
    "data:#{self.content_type};base64,#{Base64.encode64(data)}"
  end

  private

  # :nodoc:
  def self.pull_url(url, content_type = nil, limit = 10)
    uri = URI(url)
    request = Net::HTTP::Get.new(uri.request_uri)
    request.content_type = content_type if content_type

    http = Net::HTTP.new(uri.hostname, uri.port)
    if uri.scheme == 'https'
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    end

    response = http.request(request)

    if response.is_a?(Net::HTTPRedirection) && limit > 0
      location = response['location']
      self.pull_url(location, content_type, limit - 1)
    else
      response
    end
  end

  # :nodoc:
  def self.storage
    @@grid ||= Mongo::Grid.new(MongoMapper.database)
  end

  # TODO: Add ability to read from filesystem
  # :nodoc:
  def self.storage_read(id)
    self.storage.get(id).read
  end

  # TODO: Add ability to store on filesystem
  # :nodoc:
  def self.storage_write(id, data)
    self.storage.put(data, :_id => id)
  end
end
