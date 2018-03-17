fs          = require('fs')
login       = require('facebook-chat-api')
config      = require('./config.json')
login {
  email: config.username
  password: config.password
}, (err, api) ->
  if err
    return console.error(err)
  fs.writeFileSync 'appstate.json', JSON.stringify(api.getAppState())
  return
