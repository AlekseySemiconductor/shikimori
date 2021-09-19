class CreateReviews < ActiveRecord::Migration[5.2]
  def change
    create_table :reviews do |t|
      t.references :user, index: true, null: false, foreign_key: true
      t.references :anime, index: true, foreign_key: true
      t.references :manga, index: true, foreign_key: true
      t.text :body, null: false
      t.string :opinion, null: false
      t.boolean :is_written_before_release, null: false

      t.timestamps null: false
    end
  end
end
