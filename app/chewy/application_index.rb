# https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-analyze.html
# see how analyzer split phrase into tokens
=begin
curl -XPOST 'http://localhost:9200/shikimori_test_clubs/_analyze' \
  -H 'Content-Type: application/json' \
  -d'{ "analyzer": "ngram_analyzer", "text": "kaichou wa" }' | jq

curl -XPOST 'http://localhost:9200/shikimori_test_animes/_analyze' \
  -H 'Content-Type: application/json' \
  -d'{ "analyzer": "original_analyzer", "text": "Ёрмунганд" }' | jq
=end

# see how field value is splitted into tokens
=begin
curl -XPOST 'http://localhost:9200/shikimori_test_clubs/_analyze' \
  -H 'Content-Type: application/json' \
  -d'{ "field": "name.synonym", "text": "kaichou wa" }' | jq
=end
class ApplicationIndex < Chewy::Index
  ORIGINAL_FIELD = {
    type: 'text',
    index: true,
    analyzer: :original_analyzer,
    search_analyzer: :search_phrase_analyzer,
    similarity: :scripted_tfidf
  }
  EDGE_PHRASE_FIELD = {
    type: 'text',
    index: true,
    analyzer: :edge_phrase_analyzer,
    search_analyzer: :search_phrase_analyzer,
    similarity: :scripted_tfidf
  }
  EDGE_WORD_FIELD = {
    type: 'text',
    index: true,
    analyzer: :edge_word_analyzer,
    search_analyzer: :search_word_analyzer,
    similarity: :scripted_tfidf
  }
  NGRAM_FIELD = {
    type: 'text',
    index: true,
    analyzer: :ngram_analyzer,
    search_analyzer: :search_word_analyzer,
    similarity: :scripted_tfidf
  }

  DEFAULT_SETTINGS = {
    number_of_shards: 1,
    similarity: {
      scripted_tfidf: {
        type: 'scripted',
        script: {
          # here we disable idf (https://www.elastic.co/guide/en/elasticsearch/guide/master/scoring-theory.html#idf) because
          # becase in names search it just dilutes resulting score (https://stackoverflow.com/questions/33208587/elasticsearch-score-disable-idf?lq=1)
          # https://www.elastic.co/guide/en/elasticsearch/reference/current/index-modules-similarity.html\#scripted_similarity
          # "source": "double tf = Math.sqrt(doc.freq); double idf = Math.log((field.docCount+1.0)/(term.docFreq+1.0)) + 1.0; double norm = 1/Math.sqrt(doc.length); return query.boost * tf * idf * norm;"
          source: <<~TEXT.squish
            double tf = Math.sqrt(doc.freq);

            double from_min = 1.0;
            double from_max = 20.0;
            double to_min = 0.9;
            double to_max = 1.0;

            double x = doc.length;

            double percent = (x - from_min) / (from_max - from_min);
            double fixed_percent = Math.min(1, Math.max(percent, 0));
            double norm = 1.0 / (to_min + (to_max - to_min) * percent);

            return query.boost * tf * norm;
          TEXT
        }
      }
    },
    index: {
      max_ngram_diff: 20
    },
    analysis: {
      analyzer: {
        original_analyzer: {
          type: 'custom',
          tokenizer: 'keyword',
          filter: %w[lowercase asciifolding synonyms_filter],
          char_filter: %w[char_mappings]
        },
        edge_phrase_analyzer: {
          type: 'custom',
          tokenizer: 'edge_ngram_tokenizer',
          filter: %w[
            lowercase
            asciifolding
            synonyms_filter
            edgeNGram_filter
            unique_words_filter
          ],
          char_filter: %w[char_mappings]
        },
        edge_word_analyzer: {
          type: 'custom',
          tokenizer: 'standard',
          filter: %w[
            lowercase
            asciifolding
            synonyms_filter
            edgeNGram_filter
          ],
          char_filter: %w[char_mappings]
        },
        ngram_analyzer: {
          type: 'custom',
          tokenizer: 'standard',
          filter: %w[
            lowercase
            asciifolding
            synonyms_filter
            nGram_filter
            distinct_words_filter
          ],
          char_filter: %w[char_mappings]
        },
        search_phrase_analyzer: {
          type: 'custom',
          tokenizer: 'keyword',
          filter: %w[lowercase asciifolding synonyms_filter],
          char_filter: %w[char_mappings]
        },
        search_word_analyzer: {
          type: 'custom',
          tokenizer: 'standard',
          filter: %w[lowercase asciifolding synonyms_filter],
          char_filter: %w[char_mappings]
        }
      },
      tokenizer: {
        edge_ngram_tokenizer: {
          type: 'edgeNGram',
          min_gram: 1,
          max_gram: 20
        }
      },
      filter: {
        edgeNGram_filter: {
          type: 'edgeNGram',
          min_gram: 1,
          max_gram: 20,
          side: 'front'
        },
        nGram_filter: {
          type: 'nGram',
          min_gram: 1,
          max_gram: 20
        },
        distinct_words_filter: {
          type: 'unique',
          only_on_same_position: true
        },
        unique_words_filter: {
          type: 'unique'
        },
        synonyms_filter: {
          type: 'synonym',
          synonyms: [
            'i, s1, 1',
            'ii, s2, 2, Ⅱ',
            'iii, s3, 3, Ⅲ',
            'iv, s4, 4, Ⅳ',
            'v, s5, 5, Ⅴ',
            'vi, s6, 6, Ⅵ',
            'vii, s7, 7, Ⅶ',
            'viii, s8, 8, Ⅷ',
            'ix, s9, 9, Ⅸ',
            'x, s10, 10, Ⅹ'
          ]
        }
      },
      char_filter: {
        char_mappings: {
          type: 'mapping',
          mappings: [
            'Ё => Е',
            'ё => е',
            '. => \\u0020',
            '_ => \\u0020',
            '- => \\u0020',
            # https://en.wikipedia.org/wiki/Romanization_of_Japanese
            'bio => beo',
            'cha => tya',
            'chi => ti',
            'cho => tyo',
            'chu => tyu',
            'di => zi',
            'du => zu',
            'dya => ja',
            'dyo => jo',
            'dyu => ju',
            'ei => e',
            'fio => feo',
            'fu => hu',
            'gha => ga',
            'gho => go',
            'ghu => gu',
            'gue => ghe',
            'gui => ghi',
            'gv => gu',
            'ha => wa',
            'he => e',
            'ia => ja',
            'ie => ye',
            'io => jo',
            'iu => ju',
            'ji => zi',
            'kio => qeo',
            'mio => meo',
            'nho => neo',
            'nhu => niu',
            'oh => o',
            'ou => o',
            'pia => pea',
            'pio => peo',
            'piu => peu',
            'qio => qeo',
            'quio => qeo',
            'ria => rea',
            'rio => reo',
            'sh => s',
            'sha => sya',
            'shi => si',
            'sho => syo',
            'shu => syu',
            'ssh => s',
            'tch => ch',
            'tsu => tu',
            'uea => ya',
            'ueo => yo',
            'ueu => yu',
            'ui => vi',
            'uia => ya',
            'uio => yo',
            'uiu => yu',
            'uu => u',
            'va => ua',
            've => ue',
            'vea => ya',
            'veo => yo',
            'veu => yu',
            'via => ya',
            'vio => yo',
            'viu => yu',
            'vo => uo',
            'we => e',
            'wo => o',
            'zya => ja',
            'zyo => jo',
            'zyu => ju',
            'zzu => dzu'
          ]
        }
      },
    }
  }
end
