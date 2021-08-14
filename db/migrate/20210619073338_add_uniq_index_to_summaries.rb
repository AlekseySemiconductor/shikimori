class AddUniqIndexToSummaries < ActiveRecord::Migration[5.2]
  def change
    add_index :summaries, %i[user_id anime_id],
      unique: true,
      where: 'anime_id is not null'

    add_index :summaries, %i[user_id manga_id],
      unique: true,
      where: 'manga_id is not null'
  end
end
