# модель для сбора id аниме и манги, заблокированных требованиями копирайта
module Copyright
  # by Hetzner abuse team
  SCREENSHOTS = [28215,23587]
  VIDEOS = SCREENSHOTS

  # http://www.daisuki.net/anime/
  DAISUKI_COPYRIGHTED = [
    27631, # God Eater
    28215, # Saint Seiya: Soul of Gold
    23587, # The iDOLM@STER Cinderella Girls
    29975, # Gunslinger StratosAniplex
    10937, # Mobile Suit Gundam: The Origin
    24415, # Kuroko no Basket 3rd Season
    16894, # Kuroko no Basket 2nd Season
    11771, # Kuroko no Basket
    10278, # The iDOLM@STER
    21881, # Sword Art Online II
    20021, # Sword Art Online: Extra Edition
    22145, # Kuroshitsuji: Book of Circus
    25049, # Sushi Ninja
    23133, # M3: Sono Kuroki Hagane
    21437, # Buddy Complex
    18679, # Kill la Kill
    20973, # World Conquest Zvezda Plot
  ]

  COPYRIGHTED_WITH_EMAIL_WARNING = [
    19157
  ]

  # http://antipiracy.ivi.ru/Starz_Media_prizrak_gorod_mechty.pdf
  IVI_RU_COPYRIGHTED = [
    801 # Ghost in the Shell: Stand Alone Complex 2nd GIG
  ]
  IVI_RU_PLAYERS = {
    801 => 'http://www.ivi.ru/external/seriesembed/?compilationId=7561'
  }
end
