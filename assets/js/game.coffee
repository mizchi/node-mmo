{decodeObject} = Nmmo.Utils

class Nmmo.Game extends enchant.Game
  constructor: ->
    window.game = @
    # init params
    super 320, 240
    @fps = 30
    @keybind 'Z'.charCodeAt(0), 'a'
    @keybind 'X'.charCodeAt(0), 'b'
    @preload [
      "avatarBg1.png"
      "avatarBg2.png"
      "avatarBg3.png"
    ]

  onload: ->
    @rootScene.backgroundColor="#000000"
    @rootScene.addChild new enchant.AvatarBG(2)

    @rootScene.addChild _.tap new enchant.Label, (label) =>
      label.text = "MyTest"
      label.color = "white"

  bindIO: (socket) ->
    socket.on 'getPlayerData', (@playerData) =>
      socket.on 'update', ({o}) =>
        @sync(o)
        @update(o)

  sync: (objects) ->
    client_ids = (obj.user_id for obj in game.rootScene.childNodes)
    server_ids = (id for [__, __, id] in objects)

    # オブジェクトの追加
    for [x, y, id, avatar] in objects
      unless _.include client_ids, id
        @rootScene.addChild new Nmmo.Player(avatar, id)

    # オブジェクトの削除
    for node in @rootScene.childNodes when node instanceof Nmmo.Player
      unless node.user_id in server_ids
        @rootScene.removeChild node

  update: (objects) ->
    for obj in objects
      [x ,y, user_id] = obj
      player = _.find @rootScene.childNodes, (node) ->
        node.user_id is user_id
      player.decode(obj)

