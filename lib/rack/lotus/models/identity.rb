# This represents the information necessary to talk to an Author that is
# external to our node, or it represents how to talk to us.
# An Identity stores endpoints that are used to push or pull Activities from.
class Identity
  include MongoMapper::Document

  key :username
  key :domain

  key :public_key
  key :salmon_endpoint
  key :dialback_endpoint
  key :activity_inbox_endpoint
  key :activity_outbox_endpoint
  key :profile_page

  key :author, :class_name => 'Author'
  key :outbox, :class_name => 'Feed'

  timestamps!

  def self.sanitize_params(params)
    # Delete unknown keys
    params.keys.each do |k|
      unless self.keys.keys.map.include? k
        params.delete(k)
      end
    end

    # Delete immutable fields
    params.delete("_id")
  end
end
