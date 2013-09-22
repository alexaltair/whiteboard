Whiteboard
==========

An association between two models is a single fact; our code should reflect this.

Currently, Rails developers must declare each association in two separate model files. This is fine, but I think we can do better.

Whiteboard is a domain specific language (DSL) like RSpec or Rake. The DSL consists of two sections; one for the models themselves, and another for the associations.
```ruby
describe_models do
  # List your models and their attributes...
end

describe_associations do
  # How are the models connected?
end
```
Describing models
-----------------

The `describe_models` section supports two methods.
```ruby
describe_models do
  model :user do
    # List its attributes here...
  end
  models :votes, :likes, :profiles, :networks, :friends # Any size list will do.
end
```
### model
The `model` method takes the name of the Rails model and a block which describes it. It supports the following methods.
```ruby
describe_models do
  model :user do
    has name: :string, email: :string, password_digest: :string, bio: :text
    can :update_password, "Delete old password_digest and set new one."
  end
end
```
#### has
The `has` method takes key-value pairs of attributes and types. The attributes become `attr_accessible` and the types are handed to the database. The call
```ruby
has name: :string, email: :string, password_digest: :string, bio: :text
```
will produce
```ruby
class User < ActiveRecord::Base
  attr_accessible :name, :email, :password_digest, :bio
  # ...
end
```
(along with a migration file). No need to list other models here as attributes; they will be automatically included when you state the association later.
#### can
The `can` method stubs out methods in the model file. That is,
```ruby
can :update_password, "Delete old password_digest and set new one."
```
will produce
```ruby
class User < ActiveRecord::Base
  # ...
  def update_password
    # Delete old password_digest and set new one.
  end
end
```
###models
The `models` method call
```ruby
models :votes, :likes, :profiles
```
is equivalent to
```ruby
model :vote
model :like
model :profile
```
Note the difference in pluralization.

If a models attributes are brief, you can use the abbreviated block syntax, or a separate syntax altogether.
```ruby
describe_models do
  model(:post) { has body: :text }
  # or
  model :post, body: :text
end
```
The second call uses the first argument as the name, and the second hash argument is passed to `has`.

Describing associations
-----------------------
In the `describe_associations` section, each line is a statement of an association. Each statement consists of
* a symbol on the left which represents a model name
* an association method called on it
* one or many symbols on the right which represent connected models
* possible options.

```ruby
describe_associations do
  :user.has_many :posts, :comments, :votes, :likes
  :user.has_one :profile, :avatar
  :post.has_one :featured_image, through: :album
  :votes.belong_to :post, :comment, as: :votable
  :user.has_and_belongs_to_many :networks
  :user.has_and_belongs_to_many :friends, through: :friendship
end
```
Note that there's no `belongs_to` without a `through:`. These statements in model files can all be inferred from the other statements, so there is no separate command for adding them. Similarly, `has_many through:` is implemented by `has_and_belongs_to_many through:`.
### has_many
This will put `has_many` statements in the model on the left, and `belongs_to` statements in the models on the right. It will also add the left model as an attribute to the models on the left.
### has_one
### has_one through
### has_and_belongs_to_many

After running these two sections, Whiteboard will generate the expected migration files, including join tables.
### has_and_belongs_to_many through
### belongs_to as
