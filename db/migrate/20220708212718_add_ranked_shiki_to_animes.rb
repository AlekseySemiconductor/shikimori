class AddRankedShikiToAnimes < ActiveRecord::Migration[6.1]
  def change
    add_column :animes, :ranked_shiki, :integer, default: 999999, null: false
  end
end
