class ContestMatch::Finish
  method_object :contest_match

  def call
    ContestMatch.transaction do
      unvote_suspicious
      @contest_match.finish!
      @contest_match.update_column :winner_id, obtain_winner_id
    end
  end

private

  def obtain_winner_id
    if @contest_match.right_id.nil?
      @contest_match.left_id

    elsif left_votes?
      @contest_match.left_id

    elsif right_votes?
      @contest_match.right_id

    elsif !@contest_match.round.contest.swiss?
      scores? ? max_scored : @contest_match.left_id
    end
  end

  def left_votes?
    @contest_match.left_votes > @contest_match.right_votes
  end

  def right_votes?
    @contest_match.right_votes > @contest_match.left_votes
  end

  def scores?
    @contest_match.left.respond_to?(:score) &&
      @contest_match.right.respond_to?(:score)
  end

  def max_scored
    if @contest_match.right.score > @contest_match.left.score
      @contest_match.right_id
    else
      @contest_match.left_id
    end
  end

  def unvote_suspicious
    @contest_match.votes_for
      .where(voter_id: User.suspicious, voter_type: User.name)
      .find_each do |suspicious_vote|
        @contest_match.unvote_by suspicious_vote.voter
      end

    # need to reload model becase of cached field from acts_as_votable
    # without it cached_votes_left/right sometimes do not reload properly
    @contest_match = ContestMatch.find(@contest_match.id) unless Rails.env.test?
  end
end
