module Types
  module Achievement
    NEKO_GROUPS = %i[common genre franchise author]
    NekoGroup = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*NEKO_GROUPS)

    NEKO_IDS = {
      NekoGroup[:common] => %i[
        test

        animelist

        otaku
        fujoshi
        yuuri

        tsundere
        yandere
        kuudere
        moe
        genki
        gar
        oniichan
        longshounen
        shortie

        world_masterpiece_theater
        oldfag
        sovietanime
      ],
      NekoGroup[:genre] => %i[
        comedy
        romance
        fantasy
        historical
        mahou_shoujo
        dementia_psychological
        mecha
        slice_of_life
        scifi
        supernatural

        drama
        horror_thriller
        josei
        kids
        military
        mystery
        police
        space
        sports

        music
      ],
      # rubocop:disable Layout/LineLength, VariableNumber
      NekoGroup[:franchise] => %i[
        shingeki_no_kyojin tokyo_ghoul sword_art_online one_punch_man naruto re_zero boku_no_hero_academia fullmetal_alchemist science_adventure ao_no_exorcist nanatsu_no_taizai overlord code_geass ansatsu_kyoushitsu danmachi mob_psycho fairy_tail bungou_stray_dogs yahari_ore_no_seishun_love_comedy_wa_machigatteiru psycho_pass evangelion jojo_no_kimyou_na_bouken bakemonogatari kuroko_no_basket shokugeki_no_souma fate haikyuu kuroshitsuji chuunibyou_demo_koi_ga_shitai high_school_dxd kamisama_hajimemashita durarara bleach darker_than_black danganronpa hunter_x_hunter hellsing suzumiya_haruhi_no_yuuutsu k_on berserk date_a_live when_they_cry quanzhi_gaoshou zero_no_tsukaima k nisekoi black_lagoon one_piece toaru_majutsu_no_index ghost_in_the_shell magi bakuman saiki_kusuo_no_nan ore_no_imouto strike_the_blood puella_magi_sonico_magica grisaia gintama clannad free to_love_ru shingeki_no_bahamut devilman natsume_yuujinchou full_metal_panic mushishi kami_nomi_zo_shiru_sekai sora_no_otoshimono tales_of seitokai_yakuindomo kara_no_kyoukai love_live blood junjou_romantica rurouni_kenshin working sailor_moon baka_to_test_to_shoukanjuu arslan_senki quanzhi_fashi pokemon uta_no_prince_sama ashita_no_joe ushio_to_tora shakugan_no_shana jigoku_shoujo rozen_maiden persona initial_d golden_kamuy amagami_ss sayonara_zetsubou_sensei hibike_euphonium chihayafuru hakuouki xxxholic hoozuki_no_reitetsu negima baki yuru_yuri hajime_no_ippo tenchi_muyou hetalia yowamushi_pedal garo gundam hitori_no_shita terra_formars nodame_cantabile baku_tech_bakugan dragon_ball utawarerumono detective_conan inuyasha eureka_seven macross lupin_iii ginga_tetsudou little_busters gochuumon_wa_usagi_desu_ka dog_days slayers ginga_eiyuu_densetsu selector_spread_wixoss tiger_bunny brave_witches osomatsu_san diamond_no_ace ikkitousen yozakura_quartet tsubasa minami_ke aa_megami_sama black_jack koneko_no_chi genshiken school_rumble hayate_no_gotoku cardcaptor_sakura sengoku_basara idolmaster kiniro_no_corda gatchaman aquarion slam_dunk hack major teekyuu uchuu_senkan_yamato hokuto_no_ken tennis_no_ouji_sama inazuma_eleven aria huyao_xiao_hongniang show_by_rock yu_gi_oh yuu_yuu_hakusho mahou_shoujo_lyrical_nanoha douluo_dalu bang_dream majutsushi_orphen toriko idolish7 uchuu_kyoudai binan_koukou_chikyuu_boueibu_love yao_shen_ji cardfight_vanguard queen_s_blade senki_zesshou_symphogear marvel ookiku_furikabutte saint_seiya fushigi_yuugi mobile_police_patlabor saiyuki digimon starmyu doupo_cangqiong mai_hime ranma soukyuu_no_fafner angelique maria_sama saki pretty_cure transformers city_hunter glass_no_kamen aikatsu d_c seikai_no_senki beyblade taiho_shichau_zo ad_police urusei_yatsura gegege_no_kitarou pripara ze_tian_ji tamayura stitch hidamari_sketch harukanaru_toki_no_naka_de kimagure_orange_road sakura_taisen koihime_musou cutey_honey futari_wa_milky_holmes kindaichi_shounen_no_jikenbo cyborg captain_tsubasa votoms_finder ling_yu time_bokan space_cobra konjiki_no_gash_bell to_heart el_hazard mazinkaiser dirty_pair saber_marionette_j jigoku_sensei_nube di_gi_charat galaxy_angel haou_daikei_ryuu_knight
      ],
      NekoGroup[:author] => %i[
        tetsurou_araki tensai_okamura mari_okada hayao_miyazaki makoto_shinkai hiroyuki_imaishi hiroshi_hamasaki key shinichiro_watanabe yasuhiro_takemoto akiyuki_shinbou gen_urobuchi takahiro_oomori chiaki_kon mamoru_hosoda hideaki_anno type_moon isao_takahata osamu_tezuka shoji_kawamori morio_asaka kouji_morimoto masaaki_yuasa mamoru_oshii masamune_shirow shinji_aramaki kenji_kamiyama satoshi_kon yoshiaki_kawajiri clamp junichi_satou go_nagai kenji_nakamura katsuhiro_otomo kouichi_mashimo kunihiko_ikuhara yoshitaka_amano osamu_dezaki rumiko_takahashi leiji_matsumoto rintaro yoshiyuki_tomino ryousuke_takahashi toshio_maeda
      ]
      # rubocop:enable Layout/LineLength, VariableNumber
    }
    INVERTED_NEKO_IDS = NEKO_IDS.each_with_object({}) do |(group, ids), memo|
      ids.each { |id| memo[id] = NekoGroup[group] }
    end
    ORDERED_NEKO_IDS = INVERTED_NEKO_IDS.keys

    NekoId = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*ORDERED_NEKO_IDS)
  end
end
