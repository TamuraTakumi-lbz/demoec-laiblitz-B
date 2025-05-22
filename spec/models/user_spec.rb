# spec/models/user_spec.rb
require 'rails_helper'

RSpec.describe User, type: :model do
  # describeブロックでテストの対象やコンテキストを記述します
  describe 'アソシエーションのテスト' do
    # itブロックで個別のテストケースを記述します
    it 'UserRank と正しく関連付けられていること (optional)' do
      # FactoryBotを使ってテストデータを作成
      rank = create(:user_rank) # 先にUserRankを作成
      user = build(:user, user_rank: rank) # User作成時にUserRankを紐付ける
      expect(user.user_rank).to eq rank # UserからUserRankにアクセスできるか
    end

    it 'UserRank がなくても有効であること (optional: true の確認)' do
      user = build(:user, user_rank: nil)
      expect(user).to be_valid # UserRankがなくてもUserは有効
    end

    it '複数の PointDeal を持てること' do
      user = create(:user)
      deal1 = create(:point_deal, :deposit, user: user)
      deal2 = create(:point_deal, :withdrawal, user: user)

      expect(user.point_deals).to include(deal1, deal2)
      expect(user.point_deals.count).to eq 2
    end

    it 'ユーザーが削除された場合、関連する PointDeal も削除されること' do
      user = create(:user)
      create_list(:point_deal, 2, user: user) # 2つのPointDealを作成して紐付ける

      expect { user.destroy }.to change(PointDeal, :count).by(-2)
    end

    # has_many :point_deposits, through: :point_deals のテスト
    it 'PointDeal を通じて複数の PointDeposit を持てること' do
      user = create(:user)
      deal1 = create(:point_deal, user: user, point_deal_type: create(:point_deal_type, is_deposit: true))
      deal2 = create(:point_deal, user: user, point_deal_type: create(:point_deal_type, is_deposit: true))

      # PointDeposit を作成し、PointDeal に紐付ける (FactoryBot での定義が必要)
      # spec/factories/point_deposits.rb
      # FactoryBot.define do
      #   factory :point_deposit do
      #     association :point_deal
      #     deposit_amount { 100 }
      #     # exclude_from_rank_calc はデフォルトfalseを想定
      #   end
      # end
      deposit1 = create(:point_deposit, point_deal: deal1) # PointDeposit ファクトリが必要
      deposit2 = create(:point_deposit, point_deal: deal2)

      expect(user.point_deposits).to include(deposit1, deposit2)
      expect(user.point_deposits.count).to eq 2
    end

    # has_many :point_withdrawals, through: :point_deals のテストも同様に記述できます
  end

  describe 'バリデーションのテスト' do
    # ユーザー作成に必要な最小限の属性を持つ有効なファクトリがあることを確認
    it '有効なファクトリを持つこと' do
      expect(build(:user)).to be_valid
    end

    it 'ニックネームがない場合は無効であること' do
      user = build(:user, nickname: nil)
      user.valid? # バリデーションを実行
      expect(user.errors[:nickname]).to include('を入力してください') # エラーメッセージを確認 (i18n設定による)
    end

    it 'メールアドレスがない場合は無効であること' do
      user = build(:user, email: nil)
      user.valid?
      expect(user.errors[:email]).to include('を入力してください')
    end

    it '重複したメールアドレスの場合は無効であること' do
      create(:user, email: 'test@example.com') # 最初にユーザーを作成してDBに保存
      user = build(:user, email: 'test@example.com')
      user.valid?
      expect(user.errors[:email]).to include('はすでに存在します')
    end

    # Devise関連のパスワードバリデーションはDevise自身がテストしているので、
    # ここではカスタムバリデーション `password_complexity` をテストする例
    describe '#password_complexity' do
      it 'パスワードが英字のみの場合は無効であること' do
        user = build(:user, password: 'password', password_confirmation: 'password')
        user.valid?
        expect(user.errors[:password]).to include('は英字と数字の両方を含めて設定してください') # カスタムエラーメッセージに合わせる
      end

      it 'パスワードが数字のみの場合は無効であること' do
        user = build(:user, password: '123456', password_confirmation: '123456')
        user.valid?
        expect(user.errors[:password]).to include('は英字と数字の両方を含めて設定してください')
      end

      it 'パスワードが英数字混合の場合は有効であること' do
        user = build(:user, password: 'password123', password_confirmation: 'password123')
        expect(user).to be_valid
      end
    end

    it 'total_available_points が負の値の場合は無効であること' do
      user = build(:user, total_available_points: -100)
      user.valid?
      expect(user.errors[:total_available_points]).to include('は0以上の値にしてください')
    end
  end
end
