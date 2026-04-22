class Republica < ApplicationRecord
  belongs_to :user
  has_many :residents, dependent: :destroy

  validates :name, presence: true
end