json.body raw( @term.to_html)

if @user_term.persisted? && @user_term.state == "accepted" 
    json.message "THIS POLICY HAS ALREADY BEEN ACCEPTED"
    json.url reject_user_term_path(params[:id])
    json.method :put
else 
    json.message  "#{current_user.email}  please accept terms"
    json.url accept_user_term_path(params[:id])
    json.method :put
end