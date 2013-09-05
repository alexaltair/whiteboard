require './whiteboard'

describe_models do
  model :user do
    has name: :string, email: :string, password_digest: :string, bio: :text
  end
  model(:comment) { has body: :text }
  model :post, body: :text
  models :votes, :likes, :profiles
end

# describe_connections do
#   :user.has_many :posts, :comments, :votes, :likes
#   :user.has_one :profile
#   :vote.belongs_to :posts, :comments, as: :votable
# end

RailsModel.model_list.values.each(&:to_file)