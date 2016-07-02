class TorrentsController < ShikimoriController
  def create
    @klass = Anime
    anime = Anime.find(params[:id].to_i)

    parser = TokyoToshokanParser

    if params[:torrent]['url']
      parser = case params[:torrent]['url']
        when /nyaa/
          NyaaParser

        when /jishaku/
          JishakuToshokanParser

        when /tokyotosho/
          TokyoToshokanParser

        else
          redirect_to :back, alert: 'Неизвестный трекер'
          return
      end
      added = parser.grab_page URI.decode(params[:torrent]['url']), anime.id

    else
      unless params[:torrent]['link'] =~ URI::regexp
        redirect_to :back, alert: 'Link должен быть корректным URI'
        return
      end
      begin
        params[:torrent]['pubDate'] = DateTime.parse(params[:torrent]['pubDate'])
      rescue
        redirect_to :back, alert: 'PubDate должен быть корректной датой'
        return
      end

      params[:torrent]['guid'] = params[:torrent]['link'].sub('page=download', 'page=torrentinfo')
      added = TokyoToshokanParser.add_episodes(anime, [ params[:torrent] ])
    end

    if added > 0
      flash[:notice] = added == 1 ? "Новый торрент успешно добавлен" : "Новые торренты успешно добавлены"
      redirect_to anime.decorate.edit_url
    else
      redirect_to :back, alert: params[:torrent]['url'] ? 'Не найдено ни одного нового эпизода' : 'Не удалось добавить новый торрент, проверьте корректность Title'
    end
  end
end
