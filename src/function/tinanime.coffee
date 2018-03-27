request       = require('request')
cheerio       = require('cheerio')

animeNews = ->
  crawled = []
  new Promise((resolve, reject) ->
    op =
      url: 'http://tinanime.com/the-loai/tin-tuc-anime'
      method: 'GET'
    so = 0
    request op, (err, res, body) ->
      $ = cheerio.load(body)
      $('div .item-thumbnail').map (index, element) ->
        if index < 3 or index > 7 and index <= 14
          crawled[so] = element.children[0].next.children[1].attribs
          so++
        return
      resolve crawled
      return
    return
)

module.exports.animeNews = animeNews
