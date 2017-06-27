# frozen_string_literal: true

describe CosplayGallery do
  describe 'relations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to have_many :image }
    it { is_expected.to have_many(:images).dependent :destroy }
    it { is_expected.to have_many :deleted_iamges }
    it { is_expected.to have_many(:links).dependent :destroy }
    it { is_expected.to have_many :cosplayers }
    it { is_expected.to have_many :animes }
    it { is_expected.to have_many :mangas }
    it { is_expected.to have_many : }
  end

  it_behaves_like :topics_concern, :collection
end
