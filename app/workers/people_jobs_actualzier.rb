class PeopleJobsActualzier
  include Sidekiq::Worker
  sidekiq_options unique: :until_executed

  def perform
    Person.transaction do
      Person.update_all producer: false, mangaka: false, seyu: false

      Person.where(id: producer_ids).update_all producer: true
      Person.where(id: mangaka_ids).update_all mangaka: true
      Person.where(id: seyu_ids).update_all seyu: true
    end
  end

  def producer_ids
    PersonRole
      .where("
        role ilike 'Chief Producer' or
        role ilike 'Chief Producer,%' or
        role ilike '%, Chief Producer' or
        role ilike '%, Chief Producer,%' or
        role ilike 'Director' or
        role ilike 'Director,%' or
        role ilike '%, Director' or
        role ilike '%, Director,%'
      ")
      .pluck(:person_id)
      .uniq
  end

  def mangaka_ids
    PersonRole
      .where(role: Person::MANGAKA_ROLES)
      .pluck(:person_id)
      .uniq
  end

  def seyu_ids
    PersonRole
      .where(role: Person::SEYU_ROLES)
      .pluck(:person_id)
      .uniq
  end
end
