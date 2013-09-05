require './whiteboard'

create :user do
  has name: :string, email: :string, password_digest: :string, bio: :text
  has_many :posts, :comments, :votes
  has_one :profile
end

create :vote do
  has direction: :integer
  belongs_to :posts, :comments, as: :votable
end

create :post do
  has body: :text
end

RailsModel.models.values.each(&:to_file)