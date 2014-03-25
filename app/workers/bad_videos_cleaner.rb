class BadVideosCleaner
  include Sidekiq::Worker
  sidekiq_options unique: true,
                  retry: false

  def perform
    videos.each do |video|
      suggest_deletion video unless valid?(video)
    end
  end

private
  def videos
    Video
      .where(state: 'confirmed', hosting: 'youtube')
      .order(id: :desc)
      .uniq(&:url)
  end

  def valid? video
    VideoExtractor::YoutubeExtractor.new(video.url).exists?
  end

  def suggest_deletion video
    video.suggest_deletion BotsService.get_poster
  end
end
