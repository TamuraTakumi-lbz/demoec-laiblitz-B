class ApplicationController < ActionController::Base
  # before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_q

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in, keys: [:email, :password])
    # サインアップ時に許可するパラメータ
    devise_parameter_sanitizer.permit(:sign_up, keys: [
                                        :nickname,
                                        :email,
                                        :password,
                                        :password_confirmation,
                                        :last_name_kanji,
                                        :first_name_kanji,
                                        :last_name_kana,
                                        :first_name_kana,
                                        :birth_date,
                                        :is_admin
                                      ])
  end

  def after_sign_up_path_for
    # 新規登録後のリダイレクト先を指定
    root_path
  end

  def set_q
    @q = Item.ransack(params[:q])
  end
end
