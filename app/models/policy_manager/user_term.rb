module PolicyManager
  class UserTerm < ApplicationRecord
    belongs_to :user
    belongs_to :term

    validates_uniqueness_of :term_id, :scope => :user_id

    def accept!
      self.state = "accepted"
      self.save
    end

    def reject!
      self.state = "rejected"
      self.save
    end

  end
end
