# -*- encoding : utf-8 -*-
module PolicyManager::Concerns::UserBehavior
  extend ActiveSupport::Concern

  included do
    has_many :user_terms, class_name: "PolicyManager::UserTerm"
    has_many :terms, through: :user_terms
  end

  def pending_policies
    # TODO: this seems to be a litle inefficient, 
    # hint: try to do this in one query
    PolicyManager::Config.rules.select do |c|
      self.needs_policy_confirmation_for?(c.name)
    end
  end

  def confirm_all_policies!
    peding_policies.each do |c|
      term = c.terms.last
      current_user.handle_policy_for(term).accept!
    end
  end

  def reject_all_policies!
    peding_policies.each do |c|
      term = c.terms.last
      current_user.handle_policy_for(term).reject!
    end
  end

  def needs_policy_confirmation_for?(rule)
    term = policy_term_on(rule)
    user_term = policy_user_term_on(rule)
    return false if term.blank? 
    return true if user_term.blank?
    term.created_at > user_term.created_at
  end

  def is_confirmed?
  end

  def block_feature?
  end

  def policy_term_on(rule)
    category = PolicyManager::Config.rules.find{|o| o.name == rule}
    term = category.terms.last
    return if term.blank?
    term
  end

  def policy_user_term_on(rule)
    term = policy_term_on(rule)
    return if term.blank?
    self.user_terms.where(term_id: term.id).first
  end

  def handle_policy_for(term)
    self.user_terms.where(term_id: term).first_or_initialize do |member|
      member.term_id = term.id
    end
  end


  #######
  ## DATA PORTABILITY
  #######


  #######
  ## DATA FOGOTTABILITY
  #######

end