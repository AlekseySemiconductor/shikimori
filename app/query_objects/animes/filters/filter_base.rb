class Animes::Filters::FilterBase
  extend DslAttribute
  method_object :scope, :value

  dsl_attribute :dry_type
  dsl_attribute :field

  delegate :positives, :negatives, to: :terms

  module DryRescue
    def call
      super
    rescue Dry::Types::ConstraintError => e
      if field
        raise InvalidParameterError.new(field, e.input, e.message)
      else
        raise
      end
    end
  end

  def self.inherited subclass
    subclass.send :prepend, DryRescue
  end

private

  def terms
    @terms ||= Animes::Filters::Terms.new(fixed_value, dry_type)
  end

  # can be overriden in child class
  def fixed_value
    @value
  end

  def table_name
    @scope.table_name
  end

  def sanitize term
    ApplicationRecord.sanitize term
  end

  def fail_with_negative!
    dry_type["!#{negatives[0]}"]
  end
end
