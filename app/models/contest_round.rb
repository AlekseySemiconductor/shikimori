class ContestRound < ApplicationRecord
  include Translation

  # стартовая группа
  S = 'S'
  # ни разу не проигравшая группа
  W = 'W'
  # один раз проигравшая группа
  L = 'L'
  # финальная группа
  F = 'F'

  belongs_to :contest, touch: true
  has_many :matches, -> { order :id },
    class_name: ContestMatch.name,
    foreign_key: :round_id,
    dependent: :destroy

  state_machine :state, initial: :created do
    state :started
    state :finished

    event :start do
      transition created: :started, if: lambda { |round| round.matches.any? }
    end
    event :finish do
      transition started: :finished, if: lambda { |round| round.matches.all? { |v| v.finished? || v.can_finish? } }
    end

    after_transition created: :started do |round, transition|
      round.matches.select {|v| v.started_on <= Time.zone.today }.each(&:start!)
    end

    before_transition started: :finished do |round, transition|
      round.matches.select(&:started?).each(&:finish!)
    end

    after_transition started: :finished do |round, transition|
      if round.next_round
        round.next_round.start!
        round.strategy.advance_members round.next_round, round
        Messages::CreateNotification.new(round).round_finished
      else
        round.contest.finish!
      end
    end
  end

  def title_ru is_short = false
    title(is_short, Types::Locale[:ru])
  end

  def title_en is_short = false
    title(is_short, Types::Locale[:en])
  end

  # название раунда
  def title is_short = false, locale = nil
    if is_short
      "#{number}#{'a' if additional}"
    else
      additional_text = additional ? 'a' : ''
      i18n_t(
        'title',
        number: number,
        additional: additional_text,
        locale: locale
      )
    end
  end

  def to_param
    "#{number}#{'a' if additional}"
  end

  # предыдущий раунд
  def prior_round
    @prior_round ||= begin
      index = contest.rounds.index self
      if index == 0
        nil
      else
        contest.rounds[index-1]
      end
    end
  end

  # следующий раунд
  def next_round
    @next_round ||= begin
      index = contest.rounds.index self
      if index == contest.rounds.size - 1
        nil
      else
        contest.rounds[index+1]
      end
    end
  end

  # первый ли это раунд?
  def first?
    prior_round.nil?
  end

  # последний ли это раунд?
  def last?
    next_round.nil?
  end

  # стратегия турнира
  def strategy
    contest.strategy
  end
end
