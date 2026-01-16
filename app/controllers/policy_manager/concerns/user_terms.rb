module PolicyManager::Concerns::UserTerms
  extend ActiveSupport::Concern

  def accept_term(term)
    if current_user
      user_term = current_user.handle_policy_for(term)
      return if user_term.accepted?

      term.rule.on_accept.call(self) if user_term.accept! && term.rule.on_accept.is_a?(Proc)
    end

    cookies["policy_rule_#{term.rule.name}"] = {
      value: 'accepted',
      expires: 1.year.from_now
    }

    user_term
  end

  def reject_term(term)
    if current_user
      user_term = current_user.handle_policy_for(term)
      return if user_term.rejected?

      term.rule.on_reject.call(self) if user_term.reject! && term.rule.on_reject.is_a?(Proc)
    end

    cookies.delete("policy_rule_#{term.rule.name}")

    user_term
  end

  # Use callbacks to share common setup or constraints between actions.
  def policy_term_on(name)
    category = PolicyManager::Config.rules.find { |o| o.name == name }
    category.terms.last
  end
end
