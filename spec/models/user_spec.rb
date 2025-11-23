require 'rails_helper'

RSpec.describe User, type: :model do
  # ニックネームのバリデーション
  describe 'nickname' do
    it '空の場合は無効' do
      user = build(:user, nickname: nil)
      user.valid?
      expect(user.errors[:nickname]).to include("can't be blank")
    end

    it '40文字の場合は有効' do
      user = build(:user, nickname: 'a' * 40)
      expect(user).to be_valid
    end

    it '41文字以上の場合は無効' do
      user = build(:user, nickname: 'a' * 41)
      user.valid?
      expect(user.errors[:nickname]).to include('is too long (maximum is 40 characters)')
    end
  end

  # メールアドレスのバリデーション
  describe 'email' do
    it '空の場合は無効' do
      user = build(:user, email: nil)
      user.valid?
      expect(user.errors[:email]).to include("can't be blank")
    end

    it '重複している場合は無効' do
      create(:user, email: 'test@example.com')
      user = build(:user, email: 'test@example.com')
      user.valid?
      expect(user.errors[:email]).to include('has already been taken')
    end

    it '@を含まない場合は無効' do
      user = build(:user, email: 'invalidemail')
      user.valid?
      expect(user.errors[:email]).to be_present
    end
  end

  # パスワードのバリデーション
  describe 'password' do
    it '空の場合は無効' do
      user = build(:user, password: nil)
      user.valid?
      expect(user.errors[:password]).to include("can't be blank")
    end

    it '5文字以下の場合は無効' do
      user = build(:user, password: '12345', password_confirmation: '12345')
      user.valid?
      expect(user.errors[:password]).to include('is too short (minimum is 6 characters)')
    end

    it '6文字以上で半角英数字混合の場合は有効' do
      user = build(:user, password: 'abc123', password_confirmation: 'abc123')
      expect(user).to be_valid
    end

    it '英字のみの場合は無効' do
      user = build(:user, password: 'abcdef', password_confirmation: 'abcdef')
      user.valid?
      expect(user.errors[:password]).to include('は半角英数字混合で入力してください')
    end

    it '数字のみの場合は無効' do
      user = build(:user, password: '123456', password_confirmation: '123456')
      user.valid?
      expect(user.errors[:password]).to include('は半角英数字混合で入力してください')
    end

    it '全角文字を含む場合は無効' do
      user = build(:user, password: 'abc１２３', password_confirmation: 'abc１２３')
      user.valid?
      expect(user.errors[:password]).to include('は半角英数字混合で入力してください')
    end

    it 'パスワードとパスワード（確認）が一致しない場合は無効' do
      user = build(:user, password: 'abc123', password_confirmation: 'abc456')
      user.valid?
      expect(user.errors[:password_confirmation]).to include("doesn't match Password")
    end
  end

  # お名前（全角）のバリデーション
  describe 'last_name' do
    it '空の場合は無効' do
      user = build(:user, last_name: nil)
      user.valid?
      expect(user.errors[:last_name]).to include("can't be blank")
    end

    it '全角文字の場合は有効' do
      user = build(:user, last_name: '山田')
      expect(user).to be_valid
    end

    it '半角文字の場合は無効' do
      user = build(:user, last_name: 'yamada')
      user.valid?
      expect(user.errors[:last_name]).to include('は全角文字で入力してください')
    end
  end

  describe 'first_name' do
    it '空の場合は無効' do
      user = build(:user, first_name: nil)
      user.valid?
      expect(user.errors[:first_name]).to include("can't be blank")
    end

    it '全角文字の場合は有効' do
      user = build(:user, first_name: '太郎')
      expect(user).to be_valid
    end

    it '半角文字の場合は無効' do
      user = build(:user, first_name: 'taro')
      user.valid?
      expect(user.errors[:first_name]).to include('は全角文字で入力してください')
    end
  end

  # お名前カナ（全角）のバリデーション
  describe 'last_name_kana' do
    it '空の場合は無効' do
      user = build(:user, last_name_kana: nil)
      user.valid?
      expect(user.errors[:last_name_kana]).to include("can't be blank")
    end

    it '全角カタカナの場合は有効' do
      user = build(:user, last_name_kana: 'ヤマダ')
      expect(user).to be_valid
    end

    it 'ひらがなの場合は無効' do
      user = build(:user, last_name_kana: 'やまだ')
      user.valid?
      expect(user.errors[:last_name_kana]).to include('は全角カタカナで入力してください')
    end

    it '半角文字の場合は無効' do
      user = build(:user, last_name_kana: 'yamada')
      user.valid?
      expect(user.errors[:last_name_kana]).to include('は全角カタカナで入力してください')
    end
  end

  describe 'first_name_kana' do
    it '空の場合は無効' do
      user = build(:user, first_name_kana: nil)
      user.valid?
      expect(user.errors[:first_name_kana]).to include("can't be blank")
    end

    it '全角カタカナの場合は有効' do
      user = build(:user, first_name_kana: 'タロウ')
      expect(user).to be_valid
    end

    it 'ひらがなの場合は無効' do
      user = build(:user, first_name_kana: 'たろう')
      user.valid?
      expect(user.errors[:first_name_kana]).to include('は全角カタカナで入力してください')
    end

    it '半角文字の場合は無効' do
      user = build(:user, first_name_kana: 'taro')
      user.valid?
      expect(user.errors[:first_name_kana]).to include('は全角カタカナで入力してください')
    end
  end

  # 生年月日のバリデーション
  describe 'birth_date' do
    it '空の場合は無効' do
      user = build(:user, birth_date: nil)
      user.valid?
      expect(user.errors[:birth_date]).to include("can't be blank")
    end

    it '日付が設定されている場合は有効' do
      user = build(:user, birth_date: Date.new(1990, 1, 1))
      expect(user).to be_valid
    end
  end
end
