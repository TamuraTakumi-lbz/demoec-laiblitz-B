class ApplicationController < ActionController::Base
  # before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :check_published_flag, if: :common_setup?

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

  def check_published_flag
    Notification.where(is_published: false).find_each do |notification|

      if notification[:starts_at] <= Time.current
        notification[:is_published] = true
        notification.save(validate: false)
      end
      
    end
    Notification.where(is_published: true).find_each do |notification|
      if !(notification[:ends_at]==nil) && (notification[:ends_at] < Time.now)
        logger.debug("check")
        notification[:is_published] = false
        notification.save(validate: false)
      end
    end
  end

  def common_setup?
    action_name == 'index' && controller_name.in?(%w[items, notifications])
  end

  def after_sign_up_path_for
    # 新規登録後のリダイレクト先を指定
    root_path
  end
end
