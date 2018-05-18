module PolicyManager
  module TermsHelper

  	def render_term_for(policy)
  		return if policy.nil?
  		PolicyManager::Config.rules.find{|o| o.name == policy}.terms.published.last
  	end

  end
end
