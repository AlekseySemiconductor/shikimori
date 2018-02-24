Apipie.configure do |config|
  config.app_name                = 'Shikimori API'
  config.api_base_url            = '/api'
  config.doc_base_url            = '/api/doc'
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/api/**/*.rb"
  config.default_version         = '2.0'
  config.api_routes              = Rails.application.routes
  config.markup                  = Apipie::Markup::Markdown.new
  config.translate               = false
  config.generated_doc_disclaimer =
    '# AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING'

  version_placeholder = '%%VERSION_PLACEHOLDER%%'
  documentation_placeholder = '%%DOCUMENTATION_PLACEHOLDER%%'
  pagination_placeholder = '%%PAGINATION_PLACEHOLDER%%'

  app_info = <<~MARKDOWN
    ## Welcome to Shikimori API #{version_placeholder}
    This API has two versions:
      [**v2**](https://shikimori.org/api/doc/2.0.html) and
      [**v1**](https://shikimori.org/api/doc/1.0.html).
      `v2` consists of newly updated methods.
      Prefer using `v2` over `v1` when it is possible.

    **Never parse the main site**. Use `v2` and `v1` API instead.

    API works with `HTTPS` protocol only.
    <br><br>

    #{documentation_placeholder}

    ### Authentication
    OAuth2 is used for authentication. [OAuth2 guide](/oauth).<br>
    All other auth methods are deprecated and will be removed after 2018-07-01.
    <br><br>

    ### Restrictions
    API access is limited by `5rps` and `90rpm`
    <br><br>

    ### Requirements
    Add your `application name` / `website url` and your `email` / `shikimori nickname` into `User-Agent` requests header.

    Don't mimic a browser.

    Your IP address may be banned if you use API without properly set `User-Agent` header.
    <br><br>

    #{pagination_placeholder}### Third party implementations
    [Python API implementation](https://github.com/OlegWock/PyShiki) by OlegWock.

    [Node.js API implementation](https://github.com/Capster/node-shikimori) by Capster.

    [C# API implementation](https://github.com/MrModest/ShikiApiLib) by MrModest.
    <br><br>

    ### Feedback
    [@morr](http://shikimori.org/morr), [email](mailto:takandar@gmail.com)
    <br><br>
  MARKDOWN

  v1_documentation = <<~MARKDOWN
    ### Documentation for v1
    On this page below.
    <br><br>

    ### Documentation for v2
    [Click here](https://shikimori.org/api/doc/2.0.html).
    <br><br>
  MARKDOWN

  v2_documentation = <<~MARKDOWN
    ### Documentation for v1
    [Click here](https://shikimori.org/api/doc/1.0.html).
    <br><br>

    ### Documentation for v2
    On this page below.
    <br><br>
  MARKDOWN

  v1_pagination = <<~MARKDOWN
    ### Pagination in API
    When you request `N` elements from paginated API, you will get `N+1` results if API has next page.
    <br><br>

  MARKDOWN

  v2_pagination = <<~MARKDOWN
  MARKDOWN

  config.app_info['1.0'] = app_info
    .gsub(version_placeholder, 'v1')
    .gsub(documentation_placeholder, v1_documentation)
    .gsub(pagination_placeholder, v1_pagination)

  config.app_info['2.0'] = app_info
    .gsub(version_placeholder, 'v2')
    .gsub(documentation_placeholder, v2_documentation)
    .gsub(pagination_placeholder, v2_pagination)
end
