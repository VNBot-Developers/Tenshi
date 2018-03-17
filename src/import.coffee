tinanime       = require './function/tinanime.coffee'
animehot       = require './function/topanime.coffee'
animeNews   = ->
  tinanime.animeNews()

animeHot    = ->
  animehot.animeHot()

module.exports.animeNews = animeNews
module.exports.animeHot  = animeHot
