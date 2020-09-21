module BbCodes
  MULTILINE_BBCODES = %w[spoiler_block spoiler_v1 spoiler quote div center right list]
  BLOCK_TAG_EDGE_PREFIX_REGEXP = %r{
    (?:
      (?: </?div[^>]*+> | \[/?div[^\]]*+\] ) \n? |
      (?: \[/?quote[^\]]*+\] ) \n? |
      </ul> \n? |
      <li> \n? |
      (?: </?p> | \[/?p\] ) \n? |
      (?: </?center> | \[/?center\] ) \n? |
      (?: </?right> | \[/?right\] ) \n? |
      (?: </?h\d> | \[/?h\d\] ) \n? |
      <<-CODE-\d-PLACEHODLER->> \n?
    )
  }x
end
