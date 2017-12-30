class Ranobe < Manga
  KIND = 'novel'

  CHAPTER_DURATION = 40
  VOLUME_DURATION = (24 * 60) / 4 # 4 volumes per day - 6 hours per volume

  update_index('ranobes#ranobe') do
    if saved_change_to_name? || saved_change_to_russian? ||
        saved_change_to_english? || saved_change_to_japanese? ||
        saved_change_to_synonyms? || saved_change_to_score? ||
        saved_change_to_kind?
      self
    end
  end
end
