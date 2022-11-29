class Post < ApplicationRecord
  belongs_to :discussion, counter_cache: true, touch: true
  belongs_to :user, default: -> { Current.user }
  has_rich_text :body
  validates :body, presence: true

  after_create_commit -> { broadcast_append_to discussion, partial: "discussions/posts/post", post: self }
  after_update_commit -> { broadcast_replace_to discussion, partial: "discussions/posts/post", post: self }
end

#Counter cache is just a database column storing the number of children, with the value automatically updated.
#:touch If true, the associated object will be touched (the updated_at/on attributes set to now) when this record is either saved or destroyed.

#A Proc object is an encapsulation of a block of code, which can be stored in a local variable, passed to a method or another Proc, and can be called. Proc is an essential concept in Ruby and a core of its functional programming features.
