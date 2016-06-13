# frozen_string_literal: true

describe Person do
  describe 'relations' do
    it { is_expected.to have_many :person_roles }
    it { is_expected.to have_many :animes }
    it { is_expected.to have_many :mangas }
    it { is_expected.to have_many :characters }

    it { is_expected.to have_attached_file :image }
  end

  it_behaves_like :topics_concern_in_db_entry, :person
end
