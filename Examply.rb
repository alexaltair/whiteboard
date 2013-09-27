require './rails_model.rb'

describe_models do
  model :user do
    has name: :string, email: :string, password_digest: :string, bio: :text
    can :update_password, "Delete old password_digest and set new one."
  end
  model(:comment) { has body: :text }
  model :post, body: :text
  models :votes, :likes, :profiles, :networks, :friends
end

describe_associations do
  :user.has_many :posts, :comments, :votes, :likes
  :user.has_one :profile, :avatar
  :post.has_one :featured_image, through: :album
  :votes.belong_to :post, :comment, as: :votable
  :user.has_and_belongs_to_many :networks
  :user.has_and_belongs_to_many :friends, through: :friendship
end
