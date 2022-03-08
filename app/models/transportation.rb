class Transportation < ApplicationRecord
  belongs_to :participant
  has_one :trip, through: :participant

  CATEGORIES = ['bus', 'train', 'plane', 'car', 'various', 'other']

  validates :mean, inclusion: { in: CATEGORIES }
  validates :origin, :destination, presence: true

  geocoded_by :origin
  geocoded_by :destination
  after_validation :geocode, if: :will_save_change_to_origin?
  after_validation :geocode, if: :will_save_change_to_destination?

end
