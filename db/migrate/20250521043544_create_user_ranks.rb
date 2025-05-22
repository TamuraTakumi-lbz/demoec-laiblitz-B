class CreateUserRanks < ActiveRecord::Migration[7.1]
  def change
    create_table :user_ranks do |t|
      t.string "rank_name", null: false
      t.text "description", null: false
      t.float  "point_award_rate", default: 1.0,null: false

      t.timestamps
    end
  end
end
