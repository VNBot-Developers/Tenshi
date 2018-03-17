fs          = require 'fs'
path        = require 'path'
login       = require "facebook-chat-api"
config      = require '../config.json'
chalk       = client = require 'chalk'
p           = config.prefix
request     = require 'request'
moment      = require 'moment'
cheerio     = require 'cheerio'
sfunc       = require './import.coffee'
args        = []
#check file
if !fs.existsSync(path.join(__dirname, '../config.json'))
  console.log 'không tìm thấy file config :x\nvui lòng dùng lệnh npm start để cài đặt'
  process.exit()
#check file done

login {
  appState: JSON.parse fs.readFileSync 'appstate.json', 'utf8'
}, (err, api) ->
  if err
    return console.log err
  console.log chalk.green 'TenShi Bot Is Runing'
  console.log chalk.blue 'Logged as https://fb.com/' + api.getCurrentUserID()
  console.log chalk.red 'Start listening!'

  #start
  time = moment().format('MM/DD/YY, hh:mm:ss a')
  api.sendMessage 'Tenshi : connected\n' + time, api.getCurrentUserID()
  api.changeNickname 'Tenshi_Bot', api.getCurrentUserID(), api.getCurrentUserID(), (err) ->
  #closed

  api.setOptions {
  selfListen: true
  logLevel: 'warn' }
  stop = api.listen((err, msg) ->
    if err
      return console.error(err)
    if msg.senderID != api.getCurrentUserID()
      return


    #function_start
  GraphAvatarUser = ->
    avatarurl = "https://graph.facebook.com"
    #function_end

    if msg.body.indexOf("#{p}search") is 0
      string = msg.body.slice(7, msg.body.length).trim()
      text = string.split(" ").join("+")
      api.sendMessage "https://www.google.com/search?hl=vi_VN&q=#{text}", msg.threadID
    else if msg.body == "#{p}out"
      api.removeUserFromGroup api.getCurrentUserID(), msg.threadID
    else if msg.body.indexOf("#{p}google") is 0
      string = msg.body.slice(7, msg.body.length).trim()
      text = string.split(" ").join("+")
      api.sendMessage "lmgtfy.com/?q=#{text}", msg.threadID
    else if msg.body == ("#{p}animenews")
      sfunc.animeNews().then (e) ->
        e.map (element, index) ->
          write1 = fs.createWriteStream "./src/img/anime"+index.toString()+".jpg"
          request(element.src).pipe write1
          write1.on "finish", ->
            news = {
              body: element.alt
              attachment : fs.createReadStream "./src/img/anime"+index.toString()+".jpg"
            }
            api.sendMessage news , msg.threadID
            fs.unlink './src/img/anime' + index.toString() + '.jpg', (err) ->
    else if msg.body == ("#{p}topanime")
      sfunc.animeHot().then (e) ->
        e.map (element, index) ->
          write1 = fs.createWriteStream "./src/img/anime"+index.toString()+".jpg"
          request(element.src).pipe write1
          write1.on "finish", ->
            animehot = {
              body: element.alt
              attachment : fs.createReadStream "./src/img/anime"+index.toString()+".jpg"
            }
            api.sendMessage animehot , msg.threadID
            fs.unlink './src/img/anime' + index.toString() + '.jpg', (err) ->
    else if msg.body == "#{p}avatar"
      GraphAvatarUser()
      return
  )
