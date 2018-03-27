fs                             = require 'fs'
path                           = require 'path'
login                          = require 'facebook-chat-api'
config                         = require '../config.json'
chalk                          = require 'chalk'
p                              = config.prefix
request                        = require 'request'
moment                         = require 'moment'
cheerio                        = require 'cheerio'
sfunc                          = require './import.coffee'
{exec}                         = require 'child_process'
webshot                        = require 'webshot'
jimp                           = require 'jimp'
{VM}                           = require 'vm2'
rexlang                        = require './rexconfig/rexlang.json'
if !fs.existsSync(path.join(__dirname, '../appstate.json'))
  console.log 'vui lòng chạy lệnh dưới đây' + chalk.red.bold('\n=> npm start <=')
  process.exit()
login { appState: JSON.parse(fs.readFileSync('appstate.json', 'binary')) }, (err, api) ->
  if err
    return console.log(err)
  console.log chalk.green('TenShi Bot Is Runing')
  console.log chalk.blue('Logged as https://fb.com/' + api.getCurrentUserID())
  console.log chalk.red('Start listening!')
  time = moment().format('MM/DD/YY, hh:mm:ss a')
  api.sendMessage 'Tenshi : connected\n' + time, api.getCurrentUserID()
  api.changeNickname 'Tenshi_Bot', api.getCurrentUserID(), api.getCurrentUserID(), (err) ->
  api.setOptions
    selfListen: true
    logLevel: 'silent'
  stop = api.listen(((err, msg) ->
    if err
      return console.error(err)
    if msg.senderID != api.getCurrentUserID()
      return
    if msg.body.indexOf(p + 'search') == 0
      string = msg.body.slice(7, msg.body.length).trim()
      text = string.split(' ').join('+')
      api.sendMessage('https://www.google.com/search?hl=vi_VN&q=' + text, msg.threadID)
    else if msg.body == p + 'out'
      api.removeUserFromGroup(msg.senderID, msg.threadID)
    else if msg.body.indexOf(p + 'google') == 0
      string = msg.body.slice(7, msg.body.length).trim()
      text = string.split(' ').join('+')
      api.sendMessage('lmgtfy.com/?q=' + text, msg.threadID)
    else if msg.body == p + 'animenews'
      sfunc.animeNews().then((e) ->
        e.map (element, index) ->
          write1 = fs.createWriteStream('./src/img/anime' + index.toString() + '.jpg')
          request(element.src).pipe write1
          write1.on 'finish', ->
            news =
              body: element.alt
              attachment: fs.createReadStream('./src/img/anime' + index.toString() + '.jpg')
            api.sendMessage news, msg.senderID
            fs.unlink './src/img/anime' + index.toString() + '.jpg', (err) ->
      )
    else if msg.body == p + 'topanime'
      sfunc.animeHot().then((e) ->
        e.map (element, index) ->
          write1 = fs.createWriteStream('./src/img/anime' + index.toString() + '.jpg')
          request(element.src).pipe write1
          write1.on 'finish', ->
            animehot =
              body: element.alt
              attachment: fs.createReadStream('./src/img/anime' + index.toString() + '.jpg')
            api.sendMessage animehot, msg.senderID
            fs.unlink './src/img/anime' + index.toString() + '.jpg', (err) ->
      )
    else if msg.body == p + 'ping'
      api.sendMessage('Pong~', msg.threadID)
    else if msg.body == p + 'help'
      api.sendMessage('tenshi.should-be.legal/34644d', msg.threadID)
    else if msg.body.indexOf(p + 'avatar') == 0
      name = msg.body.slice(9, msg.body.length).trim()
      graphavatar = 'https://graph.facebook.com/' + Object.keys(msg.mentions) + '/picture?type=large&redirect=true&width=400&height=400'
      write1 = fs.createWriteStream('./src/img/profile' + Object.keys(msg.mentions) + '.jpg')
      request(graphavatar).pipe write1
      write1.on('finish', ->
        avatar =
          body: name
          attachment: fs.createReadStream('./src/img/profile' + Object.keys(msg.mentions) + '.jpg')
        api.sendMessage avatar, msg.threadID
        fs.unlink './src/img/profile' + Object.keys(msg.mentions) + '.jpg', (err) ->
      )
    else if msg.body.indexOf(p + 'kick') == 0
      i = 0
      results = []
      while i < Object.keys(msg.mentions).length
        api.removeUserFromGroup Object.keys(msg.mentions)[i], msg.threadID
        results.push i++
      results
    else if msg.body.indexOf(p + 'token') == 0
      apitoken = 'https://api.facebook.com/restserver.php?api_key=3e7c78e35a76a9299309885393b02d97&email=' + config.username + '&format=JSON&generate_machine_id=1&generate_session_cookies=1&locale=vi_vn&method=auth.login&password=' + config.password + '&return_ssl_resources=0&v=2.1&sig=409bf3f7f976197e0c75b4f1fd8af210'
      request(apitoken, (err, res, body) ->
        if res.statusCode == 200
          token = JSON.parse(body).access_token
          api.sendMessage('Token Của Bạn Là :\n' + '\`\`\`\n' + token + '\`\`\`', msg.senderID)
        return
      )
    else if msg.body.indexOf(p + 'sudo') == 0
      args = msg.body.split(' ').slice(1)
      if msg.senderID == api.getCurrentUserID()
        try
          code = args.join(' ')
          evaled = eval(code)
          if typeof evaled != 'string'
            evaled = require('util').inspect(evaled)
          api.sendMessage('\`\`\`javascript\n' + clean(evaled) + '\n\`\`\`', msg.threadID)
        catch _error
          err = _error
          api.sendMessage('`Lỗi` \`\`\`xl\n' + clean(err) + '\n\`\`\`', msg.threadID)
      else
        api.sendMessage ':x: Access Denied \n\nBạn không có trong `sudo` Group. feelsbadman.', msg.threadID
    else if msg.body.indexOf(p + 'eval') == 0
      args = msg.body.split(' ').slice(1)
      vm = new VM(
        console: 'inherit'
        sandbox: a: ->
          'GoodNight World!'
        timeout: 1e3
        require:
          external: true
          builtin: [
            'fs'
            'path'
          ]
        root: './'
        mock: fs: readFileSync: ->
          'YOU CAN\'T HACK ME'
)
      try
        code = args.join(' ')
        evaled = vm.run(code)
        if typeof evaled != 'string'
          evaled = require('util').inspect(evaled)
        api.sendMessage('\`\`\`javascript\n' + clean(evaled) + '\n\`\`\`', msg.threadID)
      catch _error
        err = _error
        api.sendMessage('`Lỗi` \`\`\`xl\n' + clean(err) + '\n\`\`\`', msg.threadID)
    else if msg.body.indexOf(p + 'rex') == 0
      rlang       = msg.body.split(' ').slice(1,2).join(' ')
      command     = msg.body.split(' ').slice(2).join(' ')
      lang        = replacer("$(#{rlang})", rexlang.lang)
      comargs     = replacer("$(#{lang})", rexlang.config)
      options =
        method: 'POST'
        url: 'http://rextester.com/rundotnet/api'
        formData:
          LanguageChoice: lang
          Program: command
          CompilerArgs: comargs
      request(options, (res, err, body) ->
        obj = JSON.parse(body)
        short = 2000
        gerror = obj.Errors
        gresult = obj.Result
        try
          if obj
            if gresult
              result = gresult.toString().trim().slice(0, short)
              api.sendMessage('\`\`\`bash\n' + result + '\n\`\`\`', msg.threadID)
            else
              error = gerror.toString().trim().slice(0, short)
              if error.toString() == 'Method \'main\' must be in a class \'Rextester\'.'
                api.sendMessage('\`\`\`bash\nFailed, sai cú pháp\n\`\`\`', msg.threadID)
              else if error.toString().startsWith('source_file.java:1: error:')
                api.sendMessage('⛔\n\`\`\`bash\nNgôn ngữ không hợp lệ\n\`\`\`', msg.threadID)
              else
                api.sendMessage('\`\`\`bash\n' + error + '\n\`\`\`', msg.threadID)
        catch err
          api.sendMessage('\`\`\`bash\nDone!\n\`\`\`', msg.threadID)
        return
      )
    else if msg.body.indexOf(p + 'nickname') == 0
      nickname = msg.body.slice(10, msg.body.length)
      api.changeNickname('' + nickname, msg.threadID, msg.senderID)
    else if msg.body.indexOf(p + 'cowsay') == 0
      a = '\\'
      s = ' '
      text = msg.body.slice(8, msg.body.length)
      api.sendMessage('\`\`\`\n' + s + s + s + '_____\n ' + s + '<' + s + text + s + '>\n ' + s + s + '------\n ' + s + s + s + s + s + s + s + s + s + a + s + s + s + '^__^\n ' + s + s + s + s + s + s + s + s + s + s + a + s + s + '(oo)' + a + '_______\n ' + s + s + s + s + s + s + s + s + s + s + s + s + s + '(__)' + a + s + s + s + s + s + s + s + ')' + a + '/' + a + '\n ' + s + s + s + s + s + s + s + s + s + s + s + s + s + s + s + s + s + '||----w' + s + '|\n ' + s + s + s + s + s + s + s + s + s + s + s + s + s + s + s + s + s + '||' + s + s + s + s + s + '||\n\`\`\`', msg.threadID)
    else if msg.body.indexOf(p + 'chickensay') == 0
      a = '\\'
      s = ' '
      text = msg.body.slice(12, msg.body.length)
      api.sendMessage('\`\`\`\n' + s + s + s + '_____\n <' + s + text + s + '>\n ' + s + '-----\n ' + s + s + s + s + a + '\n ' + s + s + s + s + s + a + s + s + '/' + a + '/' + a + '\n ' + s + s + s + s + s + s + s + a + s + s + s + '/\n ' + s + s + s + s + s + s + s + '|' + s + s + '0' + s + '>>\n ' + s + s + s + s + s + s + s + '|___|\n ' + s + '__((_<|' + s + s + s + '|\n (' + s + s + s + s + s + s + s + s + s + s + '|\n (__________)\n ' + s + s + s + '|' + s + s + s + s + s + s + '|\n ' + s + s + s + '|' + s + s + s + s + s + s + '|\n ' + s + s + s + '/' + a + s + s + s + s + s + '/' + a + '\n\`\`\`', msg.threadID)
    else if msg.body.indexOf(p + 'linuxsay') == 0
      a = '\\'
      s = ' '
      text = msg.body.slice(10, msg.body.length)
      api.sendMessage('\`\`\`\n' + s + '_____\n <' + s + text + s + '>\n ' + s + '-----\n ' + s + s + s + a + '\n ' + s + s + s + s + a + '\n ' + s + s + s + s + s + s + s + s + '.--.\n ' + s + s + s + s + s + s + s + '|o_o' + s + '|\n ' + s + s + s + s + s + s + s + '|:_/' + s + '|\n ' + s + s + s + s + s + s + '//' + s + s + s + a + s + a + '\n ' + s + s + s + s + s + '(|' + s + s + s + s + s + '|' + s + ')\n ' + s + s + s + s + '/' + a + '_' + s + s + s + '_/`' + a + '\n ' + s + s + s + s + a + '___)=(___/\n\`\`\`', msg.threadID)
    else if msg.body.indexOf(p + 'screenshot') == 0
      website = msg.body.slice(12, msg.body.length)
      options =
        renderDelay: 400
        userAgent: 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.101 Safari/537.36'
      shot = webshot(website, '', options)
      file = fs.createWriteStream('./src/img/website.png', encoding: 'binary')
      shot.on('data', (data) ->
        screenshot = undefined
        file.write data.toString('binary'), 'binary'
        screenshot =
          body: ''
          attachment: fs.createReadStream('./src/img/website.png')
        api.sendMessage screenshot, msg.threadID
      )
    else if msg.body.indexOf(p + 'html') == 0
      code = msg.body.slice(6, msg.body.length)
      file = fs.createWriteStream('./src/img/html/index.png', encoding: 'binary')
      options = siteType: 'html'
      shot = webshot(code, '', options)
      shot.on('data', (data) ->
        htmlshot = undefined
        file.write data.toString('binary'), 'binary'
        htmlshot =
          body: ''
          attachment: fs.createReadStream('./src/img/html/index.png')
        api.sendMessage htmlshot, msg.threadID
      )
    else if msg.body.indexOf(p + 'slap') == 0
      slapper = 'https://graph.facebook.com/' + msg.senderID + '/picture?type=large&redirect=true&width=125&height=140'
      victim = 'https://graph.facebook.com/' + Object.keys(msg.mentions) + '/picture?type=large&redirect=true&width=135&height=145'
      jimps = []
      write1 = fs.createWriteStream('./src/img/slap/slapper.jpg')
      write2 = fs.createWriteStream('./src/img/slap/victim.jpg')
      images = [
        './src/img/slap/slap.jpeg'
        './src/img/slap/slapper.jpg'
        './src/img/slap/victim.jpg'
      ]
      i = 0
      request(slapper).pipe write1
      write1.on('finish', ->
        request(victim).pipe write2
        write2.on 'finish', ->
          while i < images.length
            jimps.push jimp.read(images[i])
            i++
          Promise.all(jimps).then((data) ->
            Promise.all jimps
          ).then (data) ->
            data[0].composite data[1], 375, 40
            data[0].composite data[2], 163, 160
            data[0].write './src/img/slap/slapped.png', ->
              image =
                body: ''
                attachment: fs.createReadStream './src/img/slap/slapped.png'
              api.sendMessage image, msg.threadID
            fs.unlink '/src/img/slap/slapped.png', (err) ->
      )
    else if msg.body.indexOf(p + 'whatanime') is 0
      request()
    else if msg.body.indexOf(p + 'del' or p + 'remove') is 0
      victim = 'https://graph.facebook.com/' + Object.keys(msg.mentions) + '/picture?type=large&redirect=true&width=135&height=145'
      write1 = fs.createWriteStream('./src/img/del/victim.jpg')
      request(victim).pipe write1
      write1.on('finish', ->
        jimp.read("http://i.imgur.com/I3CrIh5.png").then((delimg) ->
          jimp.read('./src/img/del/victim.jpg').then((dimg) ->
            dimg.resize 114, 107
            delimg.composite dimg, 82, 86
            delimg.write "./src/img/del/deloutput.png", ->
              image =
                body: ''
                attachment: fs.createReadStream './src/img/del/deloutput.png'
              api.sendMessage image, msg.threadID
              fs.unlink './src/img/del/deloutput.png', (err) ->)))
    else if msg.body == p + "stats"
      packagejson = require '../package.json'
      version     = "v" + packagejson.version.toString()
      uptime      = secondsToString(process.uptime()).toString()
      memory      = Math.round(process.memoryUsage().heapUsed / 1024 / 1024) + "MB"
      jimp.read('./src/img/stats/theme.png').then (image) ->
        jimp.loadFont('./src/font/font1/font.fnt').then (font1) ->
           image.print font1, 350, 580, 'Tenshi Version :'
           image.print font1, 350, 740, 'Online Time :'
           image.print font1, 350, 920, 'Memory :'
           jimp.loadFont('./src/font/font2/gfont.fnt').then (font2) ->
             image.print font2, 820, 580, version
             image.print font2, 750, 740, uptime
             image.print font2, 650, 920, memory
             image.write './src/img/font/stats.png', (error) ->
               image =
                 body: ''
                 attachment: fs.createReadStream './src/img/font/stats.png'
               api.sendMessage image, msg.threadID
               fs.unlink './src/img/font/stats.png', (err) ->
  ),

  #More mini funtion here <3

  clean = (text) ->
    if typeof text == 'string'
      text.replace(/`/g, '`' + String.fromCharCode(8203)).replace /@/g, '@' + String.fromCharCode(8203)
    else
      text
  replacer = (input, data) ->
    reg = /\$\(([^\)]+)?\)/g
    while match = reg.exec(input)
      input = input.replace(match[0], data[match[1]])
      reg.lastIndex = 0
    input
  secondsToString = (seconds) ->
    seconds = Math.trunc(seconds)
    numdays = Math.floor(seconds % 31536000 / 86400)
    numhours = Math.floor(seconds % 31536000 % 86400 / 3600)
    numminutes = Math.floor(seconds % 31536000 % 86400 % 3600 / 60)
    numseconds = seconds % 31536000 % 86400 % 3600 % 60
    return "#{numdays}Days #{numhours}Hours #{numminutes}Min #{numseconds}Sec"
  )
