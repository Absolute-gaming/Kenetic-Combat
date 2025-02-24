extends MultiplayerSpawner

@export var playerScene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_function = spawnPlayer
	if is_multiplayer_authority():
		spawn(1)
		multiplayer.peer_connected.connect(spawn)
		multiplayer.peer_disconnected.connect(removePlayer)
		print("is_multiplayer_authority:",is_multiplayer_authority())

var players = {}

# Called every frame. 'delta' is the elapsed time since the previous frame.
func spawnPlayer(data):
	var p = playerScene.instantiate()
	p.set_multiplayer_authority(data)
	players[data] = p
	return p
	print("spawnPlayer", data)

func removePlayer(data):
	players[data].queue_free()
	players.erase(data)
	print("removePlayer", data)
