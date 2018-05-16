json.body raw(@term.to_html)

if @user_term.persisted? && @user_term.state == "accepted" 
  json.status "accepted"
  json.message "#{I18n.t("terms_app.user_terms.show.accepted.message")}"
  json.url reject_user_term_path(params[:id])
  json.method :put
elsif controller.current_user.present? 
  json.status "pending"
  json.message "#{controller.current_user.email} #{I18n.t("terms_app.user_terms.show.pending.message")}"
  json.url accept_user_term_path(params[:id])
  json.method :put
else
  json.status @user_term.state
  json.message  "#{I18n.t("terms_app.user_terms.show.pending.message")} #{params[:id]}"
  json.url accept_user_term_path(params[:id])
  json.method :put
end