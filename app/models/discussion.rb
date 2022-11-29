class Discussion < ApplicationRecord
  belongs_to :user, default: -> { Current.user }

  validates :name, presence: true

  def to_param
    "#{id}-#{name.downcase.to_string[0..50]}".parameterize
  end
end
