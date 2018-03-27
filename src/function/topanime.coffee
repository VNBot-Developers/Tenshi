request     = require('request')
fs          = require('fs')
cheerio     = require('cheerio')

animeHot = ->
  crawled = []
  new Promise((resolve, reject) ->
    op =
      url: 'http://vuighe.net'
      method: 'GET'
    so = 0
    request op, (err, res, body) ->
      $ = cheerio.load(body)
      $('section.tray.rank .tray-content.index .tray-item.index').map (index, element) ->
        crawled[so] = element.children[0].next.children[1].attribs
        so++
        return
      resolve crawled
      return
    return
)
module.exports.animeHot = animeHot
