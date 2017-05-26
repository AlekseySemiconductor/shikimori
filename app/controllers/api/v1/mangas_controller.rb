class Api::V1::MangasController < Api::V1Controller
  before_action :fetch_resource, except: [:index, :search]

  LIMIT = 50
  ORDERS = %w[
    id ranked type popularity name aired_on volumes chapters status random
  ]
  ORDERS_DESC = ORDERS.inject('') do |memo, order|
    memo +
      if order == 'random'
        '<p><code>random</code> &ndash; in random order</p>'
      else
        <<~DOC
          <p><code>#{order}</code> &ndash;
          #{I18n.t("by.#{order.gsub('type', 'kind')}", locale: :en).downcase}
          </p>
        DOC
      end
  end

  api :GET, '/mangas', 'List mangas'
  description <<~DOC
    <p>
      Most of parameters can be grouped in lists of values separated by comma:
      <ul>
        <li>
          <code>season=2016,2015</code> &ndash;
          mangas with season <code>2016 year</code>
          or with season <code>2015 year</code>
        </li>
        <li>
          <code>type=manga,one_shot</code> &ndash;
          mangas with type <code>Manga</code> or with type <code>One Shot</code>
        </li>
      </ul>
    </p>
    <p>
      Most of the parameters can be used in the subtraction mode:
      <ul>
        <li>
          <code>season=!2016,!2015</code> &ndash;
          mangas without season <code>2016 year</code>
          and without season <code>2015 year</code>
        </li>
        <li>
          <code>type=!manga,!one_shot</code> &ndash;
          mangas without type <code>Manga</code>
          and without type <code>One Shot</code>
        </li>
      </ul>
    </p>
    <p>
      Most of the parameters can be used in the combined mode:
      <ul>
        <li>
          <code>season=2016,!summer_2016</code> &ndash;
          mangas with season <code>2016 year</code> and
          without season <code>summer_2016</code>
        </li>
      </ul>
    </p>
  DOC
  param :page, :number, required: false
  param :limit, :number, required: false, desc: "#{LIMIT} maximum"
  param :order, ORDERS, required: false, desc: ORDERS_DESC
  param :type, :undef,
    required: false,
    desc: <<~DOC
      <p><strong>Validations:</strong></p>
      <ul>
        <li>
          Must be one of:
          <code>#{Manga.kind.values.join('</code>, <code>')}</code>
        </li>
      </ul>
    DOC
  param :status, :undef,
    required: false,
    desc: <<~DOC
      <p><strong>Validations:</strong></p>
      <ul>
        <li>
          Must be one of:
          <code>#{Manga.status.values.join('</code>, <code>')}</code>
        </li>
      </ul>
    DOC
  param :season, :undef,
    required: false,
    desc: <<~DOC
      <p><strong>Examples:</strong></p>
      <p><code>summer_2017</code></p>
      <p><code>spring_2016,fall_2016</code></p>
      <p><code>2016,!winter_2016</code></p>
      <p><code>2016</code></p>
      <p><code>2014-2016</code></p>
      <p><code>199x</code></p>
    DOC
  param :score, :number, required: false, desc: 'Minimal manga score'
  param :genre, :undef,
    required: false,
    desc: 'List of genre ids separated by comma'
  param :publisher, :undef,
    required: false,
    desc: 'List of publisher ids separated by comma'
  param :censored, %w[true false],
    required: false,
    desc: 'Set to `false` to allow hentai, yaoi and yuri'
  param :mylist, :undef,
    required: false,
    desc: <<~DOC
      <p>Status of manga in current user list</p>
      <p><strong>Validations:</strong></p>
      <ul>
        <li>
          Must be one of:
          <code>#{UserRate.statuses.keys.join('</code>, <code>')}</code>
        </li>
      </ul>
    DOC
  param AniMangaQuery::IDS_KEY, :undef,
    required: false,
    desc: 'List of manga ids separated by comma'
  param AniMangaQuery::EXCLUDE_IDS_KEY, :undef,
    required: false,
    desc: 'List of manga ids separated by comma'
  param :search, String,
    required: false,
    desc: 'Search phrase to filter mangas by `name`'
  def index
    limit = [[params[:limit].to_i, 1].max, 30].min

    @collection = Rails.cache.fetch cache_key, expires_in: 2.days do
      AnimesCollection::PageQuery.call(
        klass: Manga,
        params: params,
        user: current_user,
        limit: limit
      ).collection
    end

    respond_with @collection, each_serializer: MangaSerializer
  end

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/mangas/:id', 'Show a manga'
  def show
    respond_with Manga.find(params[:id]).decorate,
      serializer: MangaProfileSerializer,
      scope: view_context
  end

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/mangas/:id/roles'
  def roles
    @collection = @resource.person_roles.includes(:character, :person)
    respond_with @collection
  end

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/mangas/:id/similar'
  def similar
    @collection = @resource.related.similar
    respond_with @collection, each_serializer: MangaSerializer
  end

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/mangas/:id/related'
  def related
    @collection = @resource.related.all
    respond_with @collection
  end

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/mangas/:id/franchise'
  def franchise
    respond_with @resource, serializer: FranchiseSerializer
  end

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/mangas/:id/external_links'
  def external_links
    @collection = @resource.all_external_links
    respond_with @collection
  end

  api :GET, '/mangas/search', 'Use "List mangas" API instead', deprecated: true
  def search
    params[:limit] ||= 16
    index
  end

private

  def cache_key
    Digest::MD5.hexdigest([
      request.path,
      params.to_json,
      params[:mylist].present? ? current_user.try(:cache_key) : nil
    ].join('|'))
  end

  def fetch_resource
    @resource = Manga.find(
      CopyrightedIds.instance.restore_id(params[:id])
    ).decorate
  end
end
