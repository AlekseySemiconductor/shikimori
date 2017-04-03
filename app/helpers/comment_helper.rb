require Rails.root.join 'lib', 'string'

module CommentHelper
  include SiteHelper
  include Translation
  #include AniMangaHelper

  SIMPLE_BB_CODES = [
    :b, :s, :u, :i, :quote, :url, :img, :list, :right, :center, :solid
  ]
  COMPLEX_BB_CODES = [
    :smileys, :club, :contest, :mention, :version, :anime_video,
    :user, :message, :comment, :topic, :review, :quote, :posters, :ban,
    :spoiler
  ]#, :wall_container

  @@smileys_path = '/images/smileys/'
  @@smileys_synonym = {
    ":)" => ":-)"
  }
  @smiley_first_to_replace = [':dunno:']
  @@smiley_groups = [
    [":)",":D", ":-D", ":lol:", ":ololo:", ":evil:", "+_+", ":cool:", ":thumbup:", ":yahoo:", ":tea2:", ":star:"],
    [":oh:",":shy:", ":shy2:", ":hurray:", ":-P", ":roll:", ":!:", ":watching:", ":love:", ":love2:", ":bunch:", ":perveted:"],
    [":(", ":very sad:", ":depressed:", ":depressed2:", ":hopeless:", ":very sad2:", ":-(", ":cry:", ":cry6:", ":Cry2:", ":Cry3:", ":Cry4:"],
    [":-o", ":shock:", ":shock2:", ":scream:", ":dont want:", ":noooo:", ":scared:", ":shocked2:", ":shocked3:", ":shocked4:",
     ":tea shock:", ":frozen3:"],
    [":angry4:", ":revenge:", ":evil2:", ":twisted:", ":angry:", ":angry3:", ":angry5:", ":angry6:", ":cold:", ":strange4:", ":ball:", ":evil3:"],
    [":8):", ":oh2:", ":ooph:", ":wink:", ":dunno:", ":dont listen:", ":hypno:", ":advise:", ":bored:", ":disappointment:", ":hunf:"],#, ":idea:"
    [":hot:", ":hot2:", ":hot3:", ":stress:", ":strange3:", ":strange2:", ":strange1:", ":strange:", ":hope:", ":hope3:", ":diplom:"],
    [":hi:", ":bye:", ":sleep:", ":bow:", ":Warning:", ":Ban:", ":Bath2:", ":Im dead:", ":sick:", ":s1:", ":s3:", ":s2:", ":happy_cry:"],
    [":ill:",
     ":sad2:",
     ":bullied:", ":bdl2:",
     ":Happy Birthday:", ":flute:",
     ":cry5:",
     ":gaze:", ":hope2:",
     ":sleepy:",
     ":study:", ":study2:", ":study3:", ":gamer:",
     ":animal:",
     ":caterpillar:",
     ":cold2:", ":shocked:", ":frozen:", ":frozen2:", ":kia:", ":interested:",
     ":happy:",
     ":happy3:",
     ":water:", ":dance:", ":liar:", ":prcl:",
     ":play:",
     ":s4:", ":s:",
     ":bath:",
     ":kiss:", ":whip:", ":relax:", ":smoker:", ":smoker2:", ":bdl:", ":cool2:",
     ":V:", ":V2:", ":V3:",
     ":sarcasm:", ":angry2:", ":kya:"
    ]
  ]
  @@smileys = @@smiley_groups.flatten
  @@replaceable_smileys = @smiley_first_to_replace + (@@smileys.reverse-@smiley_first_to_replace)

  def smileys
    @@smileys
  end

  def smileys_path
    @@smileys_path
  end

  def smiley_groups
    @@smiley_groups
  end

  def smileys_to_html text, poster=nil
    @@replaceable_smileys.each do |v|
      text.gsub!(v, '<img src="%s%s.gif" alt="%s" title="%s" class="smiley" />' % [@@smileys_path, v, v, v])
    end
    text
  end

  def mention_to_html text, poster=nil
    text.gsub /\[mention=\d+\]([\s\S]*?)\[\/mention\]/ do
      nickname = $1
      "<a href=\"#{profile_url User.param_to(nickname)}\" class=\"b-mention\"><s>@</s><span>#{nickname}</span></a>"
    end
  end

  #def wall_container_to_html text, poster=nil
    #text.sub /(^[\s\S]*)(<div class="wall")/ , '<div class="height-unchecked inner-block">\1</div>\2'
  #end

  def spoiler_to_html text, nesting = 0
    return text if nesting > 10
    text = spoiler_to_html text, nesting + 1

    #/\[spoiler\](?:<br ?\/?>|\n)?(.*?)(?:<br ?\/?>|\n)?\[\/spoiler\](?:<br ?\/?>|\n)?/mi,
    #'<div class="collapse"><span class="action half-hidden" style="display: none;">развернуть</span></div><div class="collapsed spoiler">спойлер</div><div class="target spoiler" style="display: none;">\1<span class="closing"></span></div>')

    text.gsub(/
      \[spoiler (?:= (?<label> [^\[\]\n\r]*? ) )? \]
        (?:<br ?\/?> | \n | \r )?
        (?<content>
          (?:
            (?! \[\/?spoiler\] ) (?>[\s\S])
          )+
        )
        (?: <br ?\/?> | \n | \r )?
      \[\/spoiler\]
    /xi) do |match|
      '<div class="b-spoiler unprocessed">' +
        "<label>#{$~[:label] || I18n.t('markers.spoiler')}</label>" +
        "<div class='content'><div class='before'></div><div class='inner'>#{$~[:content]}</div><div class='after'></div></div>" +
      '</div>'
    end
  end

  def remove_old_tags(html)
    html
      .gsub(/(?:<|&lt;)p(?:>|&gt;)[\t\n\r]*([\s\S]*?)[\t\n\r]*(?:<|&lt;)\/p(?:>|&gt;)/i, '\1')
      .gsub(/(?:<|&lt;)br ?\/?(?:>|&gt;)/, "\n")
      .strip
      #.gsub(/[\n\r\t ]+$/x, '')
  end

  def quote_to_html text, poster=nil
    return text unless text.include?("[quote") && text.include?("[/quote]")

    text
      .gsub(/\[quote\](?:\r\n|\r|\n|<br>)?/,
        '<div class="b-quote">')
      .gsub(/\[quote=c?(\d+);(\d+);([^\]]+)\](?:\r\n|\r|\n|<br>)?/,
        '<div class="b-quote"><div class="quoteable">[comment=\1 quote]\3[/comment]</div>')
      .gsub(/\[quote=m(\d+);(\d+);([^\]]+)\](?:\r\n|\r|\n|<br>)?/,
        '<div class="b-quote"><div class="quoteable">[message=\1 quote]\3[/message]</div>')
      .gsub(/\[quote=t(\d+);(\d+);([^\]]+)\](?:\r\n|\r|\n|<br>)?/,
        '<div class="b-quote"><div class="quoteable">[topic=\1 quote]\3[/topic]</div>')
      .gsub(/\[quote=([^\]]+)\](?:\r\n|\r|\n|<br>)?/,
        '<div class="b-quote"><div class="quoteable">[user]\1[/user]</div>')
      .gsub(/\[\/quote\](?:\r\n|\r|\n|<br>)?/, '</div>')
  end

  def posters_to_html text, poster=nil
    return text unless text.include?("[anime_poster") || text.include?("[manga_poster")

    text.gsub(/\[(anime|manga)_poster=(\d+)\]/) do
      entry = ($1 == 'anime' ? Anime : Manga).find_by_id($2)
      if entry
        "<a href=\"#{url_for entry}\" title=\"#{entry.name}\"><img class=\"poster-image\" src=\"#{ImageUrlGenerator.instance.url entry, :preview}\" srcset=\"#{ImageUrlGenerator.instance.url entry, :original} 2x\" title=\"#{entry.name}\" alt=\"#{entry.name}\"/></a>"
      else
        ''
      end
    end
  end

  # TODO: refactor to bbcode class
  @@type_matchers = {
    Version => [/(\[version(?:=(\d+))?\]([^\[]*?)\[\/version\])/, :tooltip_moderations_version_url],
    AnimeVideo => [/(\[anime_video(?:=(\d+))?\]([^\[]*?)\[\/anime_video\])/, :tooltip_anime_url],
    Comment => [/(?<match>\[comment=(?<id>\d+)(?<quote> quote)?\](?<text>[^\[]*?)\[\/comment\])/, nil],
    Message => [/(?<match>\[message=(?<id>\d+)(?<quote> quote)?\](?<text>[^\[]*?)\[\/message\])/, nil],
    Topic => [/(?<match>\[(?:topic|entry)=(?<id>\d+)(?<quote> quote)?\](?<text>[^\[]*?)\[\/(?:topic|entry)\])/, nil],
    User => [/(\[(user|profile)(?:=(\d+))?\]([^\[]*?)\[\/(?:user|profile)\])/, nil],
    Review => [/(\[review=(\d+)\]([^\[]*?)\[\/review\])/, nil],
    Club => [/(\[club(?:=(\d+))?\]([^\[]*?)\[\/club\])/, nil],
    Contest => [/(\[contest(?:=(\d+))?\]([^\[]*?)\[\/contest\])/, nil],
    Ban => [/(\[ban(?:=(\d+))\])/, nil]
  }
  @@type_matchers.each do |klass, (matcher, preloader)|
    define_method("#{klass.name.to_underscore}_to_html") do |text|
      while text =~ matcher
        Honeybadger.context text: text, matcher: matcher if defined? Honeybadger

        if klass == Comment || klass == Topic || klass == Message
          url = if klass == Comment
            comment_url id: $~[:id], format: :html
          elsif klass == Message
            message_url id: $~[:id], format: :html
          else
            topic_tooltip_url id: $~[:id], format: :html
          end

          begin
            comment = klass.find $~[:id]
            user = comment.respond_to?(:user) ? comment.user : comment.from
            name = $~[:text].present? ? $~[:text] : user.nickname

            if $~[:quote].present?
              text.gsub!(
                $~[:match],
                <<~HTML
                <a href="#{profile_url user}" title="#{ERB::Util.h user.nickname}" class="bubbled b-user16" data-href="#{url}">
                <img src="#{user.avatar_url 16}" srcset="#{user.avatar_url 32} 2x" alt="#{ERB::Util.h user.nickname}" />
                <span>#{ERB::Util.h user.nickname}</span>
                </a>
                #{wrote_html(user.sex)}
                HTML
              )
            else
              text.gsub! $~[:match], "<a href=\"#{profile_url user}\" title=\"#{ERB::Util.h user.nickname}\" class=\"bubbled b-mention\" data-href=\"#{url}\"><s>@</s><span>#{name}</span></a>"
            end

          rescue
            text.gsub! $~[:match], "<span class=\"bubbled b-link\" data-href=\"#{url}\">@#{$~[:text]}</span>"
          end

        elsif klass == Review
          begin
            review = Review.find($2)
            text.gsub!($1, "<a class=\"b-link\" href=\"#{url_for [review.target, review]}\" title=\"Обзор #{review.target.name} от #{review.user.nickname}\">#{$3}</a>")
          rescue
            text.gsub! $1, "<b>#{$3}</b>"
          end

        elsif klass == User
          is_profile = $2 == 'profile'
          begin
            user = if $3.nil?
              User.find_by_nickname $4
            else
              User.find $3
            end

            text.gsub!(
              $1,
              "<a href=\"#{profile_url user}\" class=\"b-user16\" title=\"#{$4}\"><img src=\"#{user.avatar_url 16}\" srcset=\"#{user.avatar_url 32} 2x\" alt=\"#{$4}\" /><span>#{$4}</span></a>" +
              (is_profile ? '' : wrote_html(user.sex))
            )
          rescue
            text.gsub! $1, "#{$4}#{is_profile ? '' : " #{wrote_html('male')}"}"
          end

        elsif klass == Ban
          begin
            ban = Ban.find $2

            moderator_html = "<div class=\"b-user16\"><a href=\"#{profile_url ban.moderator}\" title=\"#{ERB::Util.h ban.moderator.nickname}\">
<img src=\"#{ban.moderator.avatar_url 16}\" srcset=\"#{ban.moderator.avatar_url 32} 2x\" alt=\"#{ERB::Util.h ban.moderator.nickname}\" /><span>#{ERB::Util.h ban.moderator.nickname}</span></a></div>"
            text.gsub! $1, "<div class=\"ban\">#{moderator_html}: <span class=\"resolution\">#{ban.message}</span></div>"
          rescue ActiveRecord::RecordNotFound
            text.gsub! $1, ''
            text.strip!
          end

        else # [tag=id]name[/tag]
          begin
            id = $2.nil? ? $3.to_i : $2.to_i
            entry = klass.find(id)
            entry = entry.decorate unless entry.respond_to?(:name) # для AnimeVideo
            title = $2.nil? ? entry.name : $3

            additional = if preloader
              preloader_url = send(preloader, (entry.kind_of?(AnimeVideo) ? entry.anime : entry), subdomain: false)
              " class=\"bubbled b-link\" data-tooltip_url=\"#{preloader_url}\""
            else
              " class=\"b-link\""
            end

            url = if entry.kind_of? Version
              moderations_version_url entry
            elsif entry.kind_of? Club
              club_url entry
            elsif entry.kind_of? AnimeVideo
              entry.video_url
            else
              url_for entry
            end

            text.gsub! $1, "<a href=\"#{url}\" title=\"#{entry.respond_to?(:name) ? name : title}\"#{additional}>#{title}</a>"

          rescue ActiveRecord::RecordNotFound
            text.gsub! $1, "<b>#{$3}</b>"
          end
        end
      end

      text
    end
  end

  # больше "ката" нет
  def cut(text)
    #text.sub(/\[cut\][\s\S]*/, '')
    (text || '').gsub('[h3]', '[b]')
        .gsub('[/h3]', ":[/b]\n")
        #.gsub('<li>', '<p>')
        #.gsub('</li>', '</p>')
  end

  # удаление ббкодов википедии
  def remove_wiki_codes(html)
    html.gsub(/\[\[[^\]|]+?\|(.*?)\]\]/, '\1').gsub(/\[\[(.*?)\]\]/, '\1')
  end

  def wrote_html gender
    <<~HTML.tr("\n", '')
    <span class='text-ru'>#{i18n_v('wrote', 1, gender: gender, locale: :ru)}:</span>
    <span class='text-en' data-text='#{i18n_v('wrote', 1, gender: gender, locale: :en)}:'></span>
    HTML
  end
end
