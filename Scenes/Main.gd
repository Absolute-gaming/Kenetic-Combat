extends Node

var lobby_id = 0
var peer = SteamMultiplayerPeer.new()
@onready var multiplayer_spawner = $MultiplayerSpawner

# Called when the node enters the scene tree for the first time.
func _ready():
	print("ready")
	multiplayer_spawner.spawn_function = spawn_level
	peer.lobby_created.connect(_on_lobby_created)
	Steam.lobby_match_list.connect(_on_lobby_match_list)
	open_lobby_list()
	print("isSteamRunning", Steam.isSteamRunning())

func spawn_level(data):
	var a = (load(data) as PackedScene).instantiate()
	print("spawn_level")
	return a

func _on_host_pressed():
	peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC)
	multiplayer.multiplayer_peer = peer
	multiplayer_spawner.spawn("res://Scenes/level.tscn")
	$Host.hide()
	$LobbyContainer/Lobbies.hide()
	$Refresh.hide()
	print("_on_host_pressed")

func join_lobby(id):
	peer.connect_lobby(id)
	multiplayer.multiplayer_peer = peer
	lobby_id = id
	$Host.hide()
	$LobbyContainer/Lobbies.hide()
	$Refresh.hide()
	print("join_lobby")

func _on_lobby_created(connect, id):
	if connect:
		lobby_id = id
		Steam.setLobbyData(lobby_id, "Name", str(Steam.getPersonaName()+ "'s Lobby"))
		Steam.setLobbyJoinable(lobby_id, true)
		print(lobby_id)
	print("_on_lobby_created")

func open_lobby_list():
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.requestLobbyList()
	print("open_lobby_list")

func _on_lobby_match_list(lobbies):
	
	for lobby in lobbies:
		var lobby_name = Steam.getLobbyData(lobby, "Name")
		var player_count = Steam.getNumLobbyMembers(lobby)
		
		var but = Button.new()
		but.set_text(str(lobby_name, " | Player Count: ", player_count))
		but.set_size(Vector2(100,5))
		but.connect("pressed", Callable(self, "join_lobby").bind(lobby))
		
		$LobbyContainer/Lobbies.add_child(but)
	print("_on_lobby_match_list")


func _on_refresh_pressed():
	if $LobbyContainer/Lobbies.get_child_count() > 0:
		for n in $LobbyContainer/Lobbies.get_children():
			n.queue_free()
	print("_on_refresh_pressed")
