class AddMalIdToDbEntries < ActiveRecord::Migration
  def change
    add_column :animes, :mal_id, :integer
    add_column :mangas, :mal_id, :integer
    add_column :characters, :mal_id, :integer
    add_column :people, :mal_id, :integer
  end
end
