require "aasm"

module PolicyManager
  class UserTerm < ApplicationRecord
    include AASM
    
    belongs_to :user, class_name: Config.user_resource.to_s
    belongs_to :term

    validates_uniqueness_of :term_id, :scope => :user_id

    aasm :column => :state do
      state :passive, :initial => true
      state :rejected
      state :accepted

      event :accept do
        transitions from: [:passive, :rejected], to: :accepted
      end

      event :reject do
        transitions from: [:passive, :accepted], to: :rejected
      end
    end

  end
end
