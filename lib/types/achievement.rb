module Types
  module Achievement
    NEKO_GROUPS = %i[common genre franchise]
    NekoGroup = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*NEKO_GROUPS)

    # rubocop:disable LineLength
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

        action
        drama
        horror_thriller
        josei
        kids
        military
        mystery
        police
        seinen
        space
        sports

        music
      ],
      NekoGroup[:franchise] => %i[
        naruto fate_zero shingeki_no_kyojin sword_art_online hanamonogatari kuroko_no_basket code_geass high_school_dxd kuroshitsuji boku_no_hero_academia fullmetal_alchemist fairy_tail shokugeki_no_souma durarara haikyuu nanatsu_no_taizai gintama one_piece koro_sensei_q zero_no_tsukaima ghost_in_the_shell suzumiya_haruhi_no_yuuutsu jojo_no_kimyou_na_bouken to_love_ru bleach natsume_yuujinchou berserk toaru_majutsu_no_index umineko_no_naku_koro_ni junjou_romantica bakuman pokemon magi clannad hunter_x_hunter snow_halation moon_pride mushishi full_metal_panic initial_d gundam shakugan_no_shana working tales_of_gekijou force_live detective_conan dragon_ball hajime_no_ippo rurouni_kenshin hetalia nurarihyon_no_mago blood major slayers seiren persona chiba_pedal jigoku_shoujo ushio_to_tora macross lupin_iii amon inuyasha tenchi_muyou negima minami_ke ikkitousen tennis_no_ouji_sama tsubasa aa_megami_sama utawarerumono garo selector_spread_wixoss genshiken eureka_seven megalo_box hayate_no_gotoku nen_joou puchimas zettai_karen_children dmatsu_san cardcaptor_sakura baki hack_gift tegamibachi school_rumble sket_dance aquarion_evol gatchaman diamond_no_ace aria_the_ova hikaru_no_go black_jack yes_precure queen_s_blade koneko_no_chii vivid_strike ginga_eiyuu_densetsu saint_seiya cardfight_vanguard sonic inazuma_eleven yu_gi_oh yamato digimon_savers hokuto_no_ken slam_dunk angelique senki_zesshou_symphogear d_c saiyuuki_gaiden hidamari_sketch mai_hime fushigi_yuugi ranma iron_man saki soukyuu_no_fafner mobile_police_patlabor transformers doraemon toriko yuu_yuu_hakusho uchuu_kyoudai glass_no_kamen city_hunter taiho_shichau_zo pripara futari_wa_milky_holmes votoms_finder aikatsu urusei_yatsura ad_police to_heart kimagure_orange_road maison_ikkoku candy_candy muumin sakura_taisen cyborg ehon_yose kindaichi_shounen_no_jikenbo mazinkaiser believe galaxy_angel space_cobra di_gi_charat cutey_honey dirty_pair el_hazard saber_marionette_j touch konjiki_no_gash_bell grendizer_giga mahoujin_guruguru tiger_mask captain_tsubasa ojamajo_doremi getter_robo kinnikuman super_robot_taisen_og rean_no_tsubasa zoids ultraman choujuu_kishin_dancougar dragon_quest mahou_no_princess_minky_momo juusenki_l_gaim super_doll_licca_chan haou_daikei_ryuu_knight obake_no_q_tarou pro_golfer_saru ginga_senpuu_braiger
      ]
    }
    # rubocop:enable LineLength
    INVERTED_NEKO_IDS = NEKO_IDS.each_with_object({}) do |(group, ids), memo|
      ids.each { |id| memo[id] = NekoGroup[group] }
    end
    ORDERED_NEKO_IDS = INVERTED_NEKO_IDS.keys

    NekoId = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*ORDERED_NEKO_IDS)
  end
end
