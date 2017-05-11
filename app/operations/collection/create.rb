# frozen_string_literal: true

class Collection::Create < ServiceObjectBase
  pattr_initialize :params, :locale

  def call
    Collection.create params
  end

private

  def params
    @params.merge(
      state: Types::Collection::State[:unpublished],
      locale: @locale
    )
  end
end
