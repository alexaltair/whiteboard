require './whiteboard'

describe_models do
  model :user do
    has name: :string, email: :string, password_digest: :string, bio: :text
  end
  model(:comment) { has body: :text }
  model :post, body: :text
  models :votes, :likes, :profiles, :networks, :friends
end

describe_connections do
  :user.has_many :posts, :comments, :votes, :likes
  :user.has_one :profile
  :user.has_one :foo, through: :bar
  :vote.belongs_to :posts, :comments, as: :votable
  :user.has_and_belongs_to_many :networks
  :user.has_and_belongs_to_many :friends, through: :friendship
end

# `rm -rf Examply`
`rails new Examply --skip-bundle`
Dir.chdir("Examply")
RailsModel.model_list.values.each(&:to_file)