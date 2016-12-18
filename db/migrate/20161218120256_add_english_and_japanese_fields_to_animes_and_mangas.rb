class AddEnglishAndJapaneseFieldsToAnimesAndMangas < ActiveRecord::Migration
  def change
    add_column :animes, :english_new, :string
    add_column :animes, :japanese_new, :string
    add_column :mangas, :english_new, :string
    add_column :mangas, :japanese_new, :string
  end
end
