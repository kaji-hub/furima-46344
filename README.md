# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version
* System dependencies
* Configuration
* Database creation
* Database initialization
* How to run the test suite
* Services (job queues, cache servers, search engines, etc.)
* Deployment instructions
* ...

## データベース設計

### usersテーブル（ユーザー管理）

| Column             | Type     | Options                     |
| ------------------ | -------- | --------------------------- |
| id                 | bigint   | primary_key, auto_increment |
| nickname           | string   | null: false                 |
| email              | string   | null: false, unique: true   |
| encrypted_password | string   | null: false                 |
| last_name          | string   | null: false                 |
| first_name         | string   | null: false                 |
| last_name_kana     | string   | null: false                 |
| first_name_kana    | string   | null: false                 |
| birth_date         | date     | null: false                 |
| created_at         | datetime | null: false                 |
| updated_at         | datetime | null: false                 |

#### Association

- has_many :items
- has_many :orders

### itemsテーブル（商品出品）

| Column                | Type     | Options                        |
| --------------------- | -------- | ------------------------------ |
| id                    | bigint   | primary_key, auto_increment    |
| name                  | string   | null: false                    |
| description           | text     | null: false                    |
| price                 | integer  | null: false                    |
| category_id           | integer  | null: false                    |
| condition_id          | integer  | null: false                    |
| shipping_fee_id       | integer  | null: false                    |
| prefecture_id         | integer  | null: false                    |
| scheduled_delivery_id | integer  | null: false                    |
| user_id               | bigint   | null: false, foreign_key: true |
| sold_out              | boolean  | null: false, default: false    |
| created_at            | datetime | null: false                    |
| updated_at            | datetime | null: false                    |

#### Association

- belongs_to :user
- has_one :order

#### 備考

- 画像はActive Storageで管理（active_storage_blobs, active_storage_attachmentsテーブルを使用）
- 選択式項目（category_id, condition_id, shipping_fee_id, prefecture_id, scheduled_delivery_id）はActiveHashで管理

### ordersテーブル（商品購入）

| Column     | Type     | Options                        |
| ---------- | -------- | ------------------------------ |
| id         | bigint   | primary_key, auto_increment    |
| item_id    | bigint   | null: false, foreign_key: true |
| user_id    | bigint   | null: false, foreign_key: true |
| price      | integer  | null: false                    |
| created_at | datetime | null: false                    |
| updated_at | datetime | null: false                    |

#### Association

- belongs_to :user
- belongs_to :item
- has_one :address

### addressesテーブル（配送先住所）

| Column        | Type     | Options                        |
| ------------- | -------- | ------------------------------ |
| id            | bigint   | primary_key, auto_increment    |
| order_id      | bigint   | null: false, foreign_key: true |
| postal_code   | string   | null: false                    |
| prefecture_id | integer  | null: false                    |
| city          | string   | null: false                    |
| house_number  | string   | null: false                    |
| building_name | string   |                                |
| phone_number  | string   | null: false                    |
| created_at    | datetime | null: false                    |
| updated_at    | datetime | null: false                    |

#### Association

- belongs_to :order

#### 備考

- prefecture_idはActiveHashで管理

## ER図

ER図ファイル: `furima-46344_er.dio`

