# Rescoring queries with multi-type fields
#   https://tryolabs.com/blog/2015/03/04/optimizing-elasticsearch-rescoring-queries-with-multi-type-fields/
# Strategies and Techniques for Relevance
#   https://www.compose.com/articles/elasticsearch-query-time-strategies-and-techniques-for-relevance-part-ii/
class Elasticsearch::Query::Anime < Elasticsearch::Query::QueryBase
private

  # rubocop:disable MethodLength
  def query
    {
      function_score: {
        query: {
          dis_max: {
            queries: [name_fields_query]
          }
        },
        field_value_factor: {
          field: 'weight',
          modifier: 'log',
          factor: 1
        }
      }
    }
  end
  # rubocop:enable MethodLength
end
