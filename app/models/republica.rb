class Republica < ApplicationRecord
  belongs_to :user
  has_many :residents, dependent: :destroy
  has_many :despesas, dependent: :destroy

  validates :name, presence: true
end
