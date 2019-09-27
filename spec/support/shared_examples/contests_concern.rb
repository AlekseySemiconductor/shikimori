shared_examples :contests_concern do
  describe 'contests concern' do
    describe 'associations' do
      it { is_expected.to have_many(:contest_links).dependent :destroy }
      it { is_expected.to have_many(:contest_winners).dependent :destroy }
    end
  end
end
