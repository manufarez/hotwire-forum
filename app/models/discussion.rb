class Discussion < ApplicationRecord
  belongs_to :user, default: -> { Current.user }
  belongs_to :category, counter_cache: true, touch: true
  has_many :posts, dependent: :destroy
  has_many :users, through: :posts
  has_many :discussion_subscriptions, dependent: :destroy
  #Look for discussion_subscriptions associated with a discussion where subscription_type is "optin"
  has_many :optin_subscribers, -> { where(discussion_subscriptions: { subscription_type: :optin }) },
    through: :discussion_subscriptions,
    source: :user
  has_many :optout_subscribers, -> { where(discussion_subscriptions: { subscription_type: :optout }) },
    through: :discussion_subscriptions,
    source: :user

  #discussion.category_name
  delegate :name, prefix: :category, to: :category, allow_nil: true

  validates :name, presence: true
  accepts_nested_attributes_for :posts

  #This callback is called after a record has been created.
  after_create_commit -> { broadcast_prepend_to "discussions" }
  after_update_commit -> { broadcast_replace_to "discussions" }
  after_destroy_commit -> { broadcast_remove_to "discussions" }

  broadcasts_to :category, inserts_by: :prepend

  scope :pinned_first, -> { order(pinned: :desc, updated_at: :desc)}

  def to_param
    "#{id}-#{name.downcase.to_str[0..50]}".parameterize
  end

  def subscribed_users
    #Here we include any user that has posted in the thread (so they're optin by default)
    (users + optin_subscribers).uniq - optout_subscribers
  end

  def subscription_for(user)
    return nil if user.nil?

    discussion_subscriptions.find_by(user_id: user.id)
  end

  def toggle_subscription(user)
    # If a subscription is found for the user, toggle its statuts
    if subscription = subscription_for(user)
      subscription.toggle!
    # If there is any post that the user has posted in this discussion,
    # we set the subscription status to "optout" (because a user who writes is already opted in),
    # otherwise it means he wants to "optin"
    elsif posts.where(user_id: user.id).any?
      discussion_subscriptions.create(user: user, subscription_type: "optout")
    else
      discussion_subscriptions.create(user: user, subscription_type: "optin")
    end
  end
end
