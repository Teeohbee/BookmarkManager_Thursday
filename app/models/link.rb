class Link
  include DataMapper::Resource

  property :id,    Serial
  property :title, String, required: true
  property :url,   String, required: true

  # Resource is how DataMapper works with many-to-many relationships
  # Gives link a '#tags' method to call that link's tags
  has n, :tags, through: Resource
end
