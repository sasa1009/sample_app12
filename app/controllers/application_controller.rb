class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

  def hello
    render html: 'hello, world!'
  end
  
  private
  
    # ユーザーのログインを確認する
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end
    
    # マイクロポスト検索用のストロングパラメーター
    def microposts_search_params
      params.require(:q).permit(:content_cont)
    end
end
