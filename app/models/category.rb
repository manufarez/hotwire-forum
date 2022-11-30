class Category < ApplicationRecord
  has_many :discussions, dependent: :nullify

  #Scopes always return an ActiveRecord::Relation. A class method, returns anything you want.
  scope :sorted, -> { order(name: :asc) }

  after_create_commit -> { broadcast_prepend_to 'categories' }
  after_update_commit -> { broadcast_replace_to 'categories' }
  after_destroy_commit -> { broadcast_remove_to 'categories' }

  def to_param
    "#{id}-#{name.downcase.to_s[0..50]}".parameterize
  end
end
