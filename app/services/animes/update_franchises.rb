class Animes::UpdateFranchises
  method_object

  def initialize
    @processed_ids = { Anime => [], Manga => [], Ranobe => [] }
    @franchises = []
  end

  def call scopes = [Anime, Manga]
    if scopes.first.respond_to? :find_each
      scopes.each { |scope| process scope }
    else
      process scopes
    end
  end

private

  def process scope
    scope.send(scope.respond_to?(:find_each) ? :find_each : :each) do |entry|
      next if @processed_ids[entry.class].include? entry.id
      chronology = Animes::ChronologyQuery.new(entry).fetch

      if chronology.many?
        add_franchise chronology
      else
        remove_franchise entry
      end
    end
  end

  def add_franchise entries
    franchise = Animes::FranchiseName.call entries, @franchises

    entries.each do |entry|
      @processed_ids[entry.class] << entry.id
      entry.update franchise: franchise
    end
  end

  def remove_franchise entry
    @processed_ids[entry.class] << entry.id
    entry.update franchise: nil
  end
end
