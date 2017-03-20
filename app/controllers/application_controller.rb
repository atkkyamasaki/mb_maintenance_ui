class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception

    before_action :before_action_login, if: :use_before_action?

    def current_user
        if session[:user_id]
            # @current_user が 'nil' か 'false' ならログインユーザーを代入
            current_user ||= User.find(session[:user_id])
        end
    end



    private

    def before_action_login

        if current_user == nil 
            redirect_to :controller => 'logins', :action => 'show'
        end

    end

    def use_before_action?
        true
    end

end
