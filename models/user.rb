# example model file
class User
  include DataMapper::Resource

  property :id,         Serial
  property :name,       String, :required => true, :unique => true
  property :password,   BCryptHash, :required => true
  property :created_at, DateTime
  property :updated_at, DateTime

  validates_presence_of :name
end