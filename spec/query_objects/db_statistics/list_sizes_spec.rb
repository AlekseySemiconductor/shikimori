describe DbStatistics::ListSizes do
  subject { described_class.call scope }
  let(:scope) { UserRate.where(target_type: 'Manga') }

  10.times do |i|
    let!(:"manga_#{i}") { create :manga }
  end

  10.times do |i|
    let!(:"manga_rate_#{i}") do
      create :user_rate, :completed, user: user, target: send(:"manga_#{i}")
    end
  end

  it do
    is_expected.to have(described_class::INTERVALS.size).keys
    expect(subject['10']).to eq 1
    expect(subject.values[1..-1].all?(&:zero?)).to eq true
  end
end
