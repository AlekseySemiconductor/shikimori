class CreateSummaries < ActiveRecord::Migration[5.2]
  def change
    create_table :summaries do |t|
      t.references :user, index: true, null: false, foreign_key: true
      t.references :anime, index: true, foreign_key: true
      t.references :manga, index: true, foreign_key: true
      t.text :body, null: false
      t.boolean :is_positive, null: false

      t.timestamps null: false
    end
  end
end
