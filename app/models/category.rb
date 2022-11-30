class Category < ApplicationRecord
  has_many :discussions, dependent: :nullify

  #Scopes always return an ActiveRecord::Relation. A class method, returns anything you want.
  scope :sorted, -> { order(name: :asc) }
end
