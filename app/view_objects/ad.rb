class Ad < ViewObjectBase
  # present advertur blocks
  # block_1: [92_129, 2_731],
  # block_2: [92_445, 1_256],
  # block_3: [92_485, nil]

  BANNERS = {
    Types::Ad::Type[:special_x300] => {
      provider: Types::Ad::Provider[:special],
      url: 'https://www.filmpro.ru/special/bsd',
      images: (2..2).map do |i|
        {
          src: "/assets/globals/events/special_#{i}.jpg",
          src_2x: "/assets/globals/events/special_#{i}@2x.jpg"
        }
      end,
      # rules: {
      #   cookie: 'i2',
      #   shows_per_week: 30
      # },
      placement: Types::Ad::Placement[:menu],
      platform: Types::Ad::Platform[:desktop]
    },
    Types::Ad::Type[:special_x1170] => {
      provider: Types::Ad::Provider[:special],
      url: 'https://www.filmpro.ru/special/bsd',
      images: (1..1).map do |i|
        {
          src: "/assets/globals/events/special_#{i}.jpg",
          src_2x: "/assets/globals/events/special_#{i}@2x.jpg"
        }
      end,
      # images: [{
      #   url: 'https://creagames.com/ref/575?utm_source=shikimori&utm_medium=banner',
      #   src: '/assets/globals/events/special_1.jpg?1',
      #   src_2x: '/assets/globals/events/special_1@2x.jpg?1'
      # }, {
      #   url: 'https://creagames.com/games/kr?utm_source=shikimori&utm_medium=banner',
      #   src: '/assets/globals/events/special_2.jpg',
      #   src_2x: '/assets/globals/events/special_2@2x.jpg'
      # }],
      placement: Types::Ad::Placement[:content],
      platform: Types::Ad::Platform[:desktop]
    },
    Types::Ad::Type[:advrtr_x728] => {
      provider: Types::Ad::Provider[:advertur],
      advertur_id: 1_256,
      width: 728,
      height: 90,
      placement: Types::Ad::Placement[:content],
      platform: Types::Ad::Platform[:desktop]
    },
    Types::Ad::Type[:advrtr_240x400] => {
      provider: Types::Ad::Provider[:advertur],
      advertur_id: 2_731,
      width: 240,
      height: 400,
      placement: Types::Ad::Placement[:menu],
      platform: Types::Ad::Platform[:desktop]
    },
    Types::Ad::Type[:yd_300x600] => {
      provider: Types::Ad::Provider[:yandex_direct],
      yandex_id: 'R-A-227837-4',
      placement: Types::Ad::Placement[:menu],
      platform: Types::Ad::Platform[:desktop]
    },
    Types::Ad::Type[:yd_240x500] => {
      provider: Types::Ad::Provider[:yandex_direct],
      yandex_id: 'R-A-227837-5',
      placement: Types::Ad::Placement[:menu],
      platform: Types::Ad::Platform[:desktop]
    },
    Types::Ad::Type[:yd_240x400] => {
      provider: Types::Ad::Provider[:yandex_direct],
      yandex_id: 'R-A-227837-2',
      placement: Types::Ad::Placement[:menu],
      platform: Types::Ad::Platform[:desktop]
    },
    Types::Ad::Type[:yd_horizontal] => {
      provider: Types::Ad::Provider[:yandex_direct],
      yandex_id: 'R-A-227837-7',
      placement: Types::Ad::Placement[:content],
      platform: Types::Ad::Platform[:desktop]
    },
    Types::Ad::Type[:mt_300x250] => {
      provider: Types::Ad::Provider[:mytarget],
      mytarget_id: '239817',
      placement: Types::Ad::Placement[:menu],
      platform: Types::Ad::Platform[:desktop]
    },
    Types::Ad::Type[:mt_240x400] => {
      provider: Types::Ad::Provider[:mytarget],
      mytarget_id: '239815',
      placement: Types::Ad::Placement[:menu],
      platform: Types::Ad::Platform[:desktop]
    },
    Types::Ad::Type[:mt_300x600] => {
      provider: Types::Ad::Provider[:mytarget],
      mytarget_id: '239819',
      placement: Types::Ad::Placement[:menu],
      platform: Types::Ad::Platform[:desktop]
    },
    Types::Ad::Type[:mt_728x90] => {
      provider: Types::Ad::Provider[:mytarget],
      mytarget_id: '239978',
      placement: Types::Ad::Placement[:content],
      platform: Types::Ad::Platform[:desktop]
    },
    Types::Ad::Type[:mt_footer] => {
      provider: Types::Ad::Provider[:mytarget],
      mytarget_id: '99457',
      placement: Types::Ad::Placement[:footer],
      platform: Types::Ad::Platform[:mobile]
    }
  }

  META_TYPES = {
    Types::Ad::Meta[:menu_300x250] => [
      # Types::Ad::Type[:special_x300],
      # Types::Ad::Type[:mt_300x250],
      Types::Ad::Type[:yd_240x400],
      Types::Ad::Type[:advrtr_240x400]
    ],
    Types::Ad::Meta[:menu_240x400] => [
      Types::Ad::Type[:special_x300],
      # Types::Ad::Type[:mt_240x400],
      Types::Ad::Type[:yd_240x500],
      Types::Ad::Type[:advrtr_240x400]
    ],
    Types::Ad::Meta[:menu_300x600] => [
      Types::Ad::Type[:special_x300],
      # Types::Ad::Type[:mt_300x600],
      Types::Ad::Type[:yd_300x600],
      Types::Ad::Type[:advrtr_240x400]
    ],
    Types::Ad::Meta[:horizontal] => [
      # Types::Ad::Type[:mt_728x90],
      Types::Ad::Type[:yd_horizontal],
      Types::Ad::Type[:advrtr_x728]
    ],
    Types::Ad::Meta[:footer] => [
      Types::Ad::Type[:mt_footer]
    ],
    Types::Ad::Meta[:special_x1170] => [
      Types::Ad::Type[:special_x1170]
    ]
  }

  attr_reader :banner_type, :policy

  def initialize meta
    meta = Types::Ad::Meta[:menu_240x400] if switch_to_x240? meta
    meta = Types::Ad::Meta[:menu_300x600] if switch_to_x300? meta

    META_TYPES[Types::Ad::Meta[meta]].each do |type|
      switch_banner Types::Ad::Type[type]
      break if policy.allowed?
    end
  end

  def allowed?
    # # temporarily disable advertur
    # if provider == Types::Ad::Provider[:advertur] &&
        # h.params[:action] != 'advertur_test' && Rails.env.production? &&
        # h.current_user&.id != 1
      # return false
    # end

    if h.controller.instance_variable_get controller_key(banner[:placement])
      false
    else
      policy.allowed? && (!@rules || @rules.show?)
    end
  end

  def provider
    banner[:provider]
  end

  def platform
    banner[:platform]
  end

  def ad_params
    return unless yandex_direct?

    {
      blockId: banner[:yandex_id],
      renderTo: @banner_type,
      async: true
    }
  end

  def css_class
    "spnsrs_#{@banner_type}"
  end

  def to_html
    finalize

    <<-HTML.gsub(/\n|^\ +/, '')
      <div class="b-spnsrs-#{@banner_type}">
        <center>
          #{ad_html}
        </center>
      </div>
    HTML
  end

private

  def switch_banner banner_type
    @banner_type = banner_type
    @policy = build_policy
    @rules = build_rules if banner[:rules]
  end

  def build_policy
    AdsPolicy.new(
      user: h.current_user,
      ad_provider: provider,
      is_ru_host: h.ru_host?,
      is_shikimori: h.shikimori?,
      is_disabled: h.cookies["#{css_class}_disabled"].present?
    )
  end

  def build_rules
    Ads::Rules.new banner[:rules], h.cookies[banner[:rules][:cookie]]
  end

  def banner
    BANNERS[@banner_type]
  end

  def yandex_direct?
    provider == Types::Ad::Provider[:yandex_direct]
  end

  def mytarget?
    provider == Types::Ad::Provider[:mytarget]
  end

  def banner?
    banner[:images].present?
  end

  def html?
    banner[:html].present?
  end

  def iframe?
    provider == Types::Ad::Provider[:advertur]
  end

  def ad_html # rubocop:disable all
    if yandex_direct?
      "<div id='#{@banner_type}'></div>"

    elsif mytarget?
      <<-HTML.squish
        <ins
          class="mrg-tag"
          style="display:inline-block;text-decoration: none;"
          data-ad-client="ad-#{banner[:mytarget_id]}"
          data-ad-slot="#{banner[:mytarget_id]}"></ins>
      HTML

    elsif banner?
      image = banner[:images].sample

      image_html =
        if image[:src_2x]
          "<img src='#{image[:src]}' srcset='#{image[:src_2x]} 2x'>"
        else
          "<img src='#{image[:src]}'>"
        end

      "<a href='#{banner[:url] || image[:url]}'>#{image_html}</a>"
    elsif html?
      banner[:html]

    elsif iframe?
      "<iframe src='#{advertur_url}' width='#{banner[:width]}px' "\
        "height='#{banner[:height]}px'>"

    else
      raise ArgumentError
    end
  end

  def advertur_url
    h.spnsr_url(
      banner[:advertur_id],
      width: banner[:width],
      height: banner[:height],
      container_class: css_class,
      protocol: false
    )
  end

  def switch_to_x240? meta
    [
      Types::Ad::Meta[:menu_300x600],
      Types::Ad::Meta[:menu_300x250]
    ].include?(meta) && h.current_user&.preferences&.body_width_x1000?
  end

  def switch_to_x300? meta
    [
      Types::Ad::Meta[:menu_240x400]
    ].include?(meta) && h.params[:controller].in?(%w[topics])
  end

  def finalize
    h.controller.instance_variable_set controller_key(banner[:placement]), true

    if @rules
      h.cookies[banner[:rules][:cookie]] = {
        value: @rules.export_shows,
        expires: 1.week.from_now
      }
    end
  end

  def controller_key placement
    :"@is_#{placement}_ad_shown"
  end
end
