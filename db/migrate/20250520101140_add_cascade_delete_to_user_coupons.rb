class AddCascadeDeleteToUserCoupons < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :user_coupons, :users
    add_foreign_key    :user_coupons, :users, on_delete: :cascade
    
    remove_foreign_key :user_coupons, :coupons
    add_foreign_key    :user_coupons, :coupons, on_delete: :cascade
  end
end
