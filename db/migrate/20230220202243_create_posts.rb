class CreatePosts < ActiveRecord::Migration[7.0]
  def change
    create_table :posts do |t|
      t.text :user
      t.text :content
      t.datetime :create_date
      t.timestamps
    end

    create_table :comments do |t|
      t.belongs_to :post, index: true, foreign_key: true
      t.text :content
      t.datetime :created_date
      t.timestamps
    end
  end
end
