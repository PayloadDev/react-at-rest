_ =
  endsWith:      require 'lodash/string/endsWith'
  isNaN:         require 'lodash/lang/isNaN'
  isPlainObject: require 'lodash/lang/isPlainObject'


module.exports = {
  # Remove pluralization from a string
  #
  # @example
  #   singularize('proposalRequests') => 'proposalRequest'
  #   singularize('proposalRequest') => 'proposalRequest'
  #
  # @param str [String]
  #
  # @return [String]
  singularize: (str) ->
    if _.endsWith(str, 's')
      str.substring(0, str.length-1)
    else
      str


  # Pluralizes a string when the count requires a pluralized form
  # @example
  #   pluralize(5, 'cat') => '5 cats'
  #   pluralize(1, 'cat') => '1 cat'
  #   pluralize(2, 'mouse', 'mice') => '2 mice'
  #
  # @param count      [Number] Number of items
  # @param singular   [String] Singular version of the string
  # @param plural     [String] Optional. Pluralized form of the string if appending an 's' is incorrect
  pluralize: (count, singular, plural) ->
    plural = singular + 's' unless plural?
    if count isnt 1
      plural
    else
      singular


  # capitalize the first letter of a string
  #
  # @example
  #   capitalize 'foo' => 'Foo'
  #
  # @param str [String]
  #
  # @return [String]
  capitalize: (str) ->
    if str[0]?
      str[0].toUpperCase() + str[1...]
    else
      str


  # convert to an integer, but return 'undefined' if the number cannot be parsed
  #
  # @example
  #   toInt('99') => 99
  #   toInt('99px') => 99
  #   toInt(undefined) => undefined
  #
  # @param str [String]
  #
  # @return Integer
  toInt: (str) ->
    int = parseInt str, 10
    if _.isNaN int
      undefined
    else
      int


  # Simplified version of jQuery's 'param' method
  toQueryStr: (query) ->
    return query if typeof query is 'string'
    queryStr = []
    for key, value of query
      value = value ? ''
      if _.isPlainObject value
        # unroll nested objects
        for subkey, subvalue of value
          queryStr.push "#{encodeURIComponent key}[#{encodeURIComponent subkey}]=#{encodeURIComponent subvalue}"
      else
        queryStr.push "#{encodeURIComponent key}=#{encodeURIComponent value}"

    queryStr.join('&').replace(/%20/g, '+').replace(/%7C/g, '|').replace(/%2C/g, ',')


  # replace just the query string in a React Router route
  #
  replaceQuery: (history, location, query) ->
    url = "#{location.pathname}?#{@toQueryStr query}"
    # backwards compatibility with react-router 1.0.0
    if history.replace?
      history.replace url
    else
      history.replaceState null, url


  # set the page's title
  setPageTitle: (title) ->
    document.title = "#{title} #{t 'pagetitles.postfix'}"


  # Truncates string based on length and appends '...'
  #
  # @example
  #   truncate 'Really long string', 10 => 'Really long...'
  #
  # @param str        [String]
  # @param length     [Integer]
  # @param breakWords [Boolean]
  #
  # @return [String]
  truncate: (str='', length=128, breakWords=true) ->
    unless breakWords
      while str[length+1] not in [' ',',','.'] and str[length]?
        length++
    truncatedStr = str[..length]
    truncatedStr += '...' if str.length > length
    truncatedStr

}
