# This represents a person. They act by creating Activities. These Activities
# go into Feeds. Feeds are collected into Aggregates.
class Author
  include MongoMapper::Document

  key :id
  key :nickname
  key :extended_name
  key :uri
  key :email
  key :name
  key :organization
  key :address
  key :account
  key :gender
  key :note
  key :display_name
  key :preferred_username
  key :birthday
  key :anniversary

  one :embedded_avatar

  timestamps!

  def self.sanitize_params(params)
    # Delete unknown subkeys
    if params["extended_name"]
      params["extended_name"].keys.each do |k|
        if ["formatted", "given_name", "family_name", "honorific_prefix",
            "honorific_suffix", "middle_name"].include?(k)
          params["extended_name"][(k.to_sym rescue k)] =
            params["extended_name"].delete(k)
        else
          params["extended_name"].delete(k)
        end
      end
    end

    if params["organization"]
      params["organization"].keys.each do |k|
        if ["name", "department", "title", "type", "start_date", "end_date",
            "description"].include?(k)
          params["organization"][(k.to_sym rescue k)] =
            params["organization"].delete(k)
        else
          params["organization"].delete(k)
        end
      end
    end

    if params["address"]
      params["address"].keys.each do |k|
        if ["formatted", "street_address", "locality", "region", "country",
            "postal_code"].include?(k)
          params["address"][(k.to_sym rescue k)] =
            params["address"].delete(k)
        else
          params["address"].delete(k)
        end
      end
    end

    # Delete unknown keys
    params.keys.each do |k|
      unless self.keys.keys.include?(k) ||
             self.keys.keys.map(&:intern).include?(k)
        params.delete(k)
      end
    end

    # Delete immutable fields
    params.delete("_id")

    params
  end
end
