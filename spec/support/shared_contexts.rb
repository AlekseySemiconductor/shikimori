shared_context :authenticated do |role|
  let(:user) { create :user, role, :day_registered }
  before { sign_in user }
end

shared_context :back_redirect do
  let(:back_url) { 'where_i_came_from' }
  before { request.env['HTTP_REFERER'] = back_url }
end

shared_context :view_object_warden_stub do
  before do
    view_context = view.h

    view_context.request.env['warden'] ||= WardenStub.new
    allow(view_context).to receive(:current_user).and_return(
      user ? user.decorate : nil
    )
    def view_context.censored_forbidden?; true; end
    # allow(view_context).to receive(:censored_forbidden?).and_return true
    allow(view_context.controller).to receive(:default_url_options)
      .and_return ApplicationController.default_url_options
  end

  after do
    view.h.request.env['warden'] = nil
    view.h.instance_variable_set '@current_user', nil
    view.h.controller.instance_variable_set '@current_user', nil
    view.h.controller.instance_variable_set '@decorated_current_user', nil
    # в каких-то случаях params почему-то не очищается
    # словил падение view object спеки от того, что в params лежали данные от
    # предыдущего контроллера
    view.h.params.delete_if { true }
  end
end

shared_context :seeds do
  let(:user) { seed :user }

  let(:offtopic_forum) { seed :offtopic_forum }
  let(:reviews_forum) { seed :reviews_forum }
  let(:animanga_forum) { seed :animanga_forum }
  let(:contests_forum) { seed :contests_forum }
  let(:clubs_forum) { seed :clubs_forum }
  let(:cosplay_forum) { seed :cosplay_forum }

  include_context :sticky_topics
end

shared_context :sticky_topics do
  let(:offtopic_topic) { seed :offtopic_topic }
  let(:site_rules_topic) { seed :site_rules_topic }
  let(:faq_topic) { seed :faq_topic }
  let(:description_of_genres_topic) { seed :description_of_genres_topic }
  let(:ideas_and_suggestions_topic) { seed :ideas_and_suggestions_topic }
  let(:site_problems_topic) { seed :site_problems_topic }

  let(:sticky_topics_count) { 6 }
  let(:all_sticky_topics) do
    [
      offtopic_topic,
      site_rules_topic,
      faq_topic,
      description_of_genres_topic,
      ideas_and_suggestions_topic,
      site_problems_topic
    ]
  end
end

shared_examples_for :success_resource_change do |type|
  it do
    expect(resource).to be_persisted
    expect(resource).to have_attributes(params)
    expect(response).to have_http_status :success

    if type == :api
      expect(json).to_not include :html
    elsif type == :frontend
      expect(json).to include :html
    else
      raise ArgumentError, "unknown type #{type} (allowed :api or :frontend)"
    end

    expect(response.content_type).to eq 'application/json'
  end
end

shared_examples_for :failure_resource_change do
  it do
    expect(resource).to_not be_valid
    expect(resource.changes).to_not be_empty

    expect(json).to include :errors
    expect(json[:errors]).to be_kind_of Array

    expect(response.content_type).to eq 'application/json'
    expect(response).to have_http_status 422
  end
end
