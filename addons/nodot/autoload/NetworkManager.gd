extends Node

var enabled = false
var is_host = false

signal host_started(id: int, display_name: String)
signal peer_connected(id: int, display_name: String)

var multiplayer_peer = ENetMultiplayerPeer.new()

func join(address: String, port: int, new_display_name: String = ""):
	multiplayer_peer.create_client(address, port)
	multiplayer.multiplayer_peer = multiplayer_peer

func host(port: int, new_display_name: String = ""):
	is_host = true
	multiplayer_peer.create_server(port)
	multiplayer.multiplayer_peer = multiplayer_peer
	multiplayer_peer.peer_connected.connect(func (id = 1):
		_on_peer_connected(id, new_display_name)
		)
	multiplayer_peer.peer_disconnected.connect(_on_peer_disconnected)
	emit_signal("host_started", multiplayer.get_unique_id(), new_display_name)

func _on_peer_connected(id = 1, new_display_name: String = ""):
	print("%s connected" % id)
	emit_signal("peer_connected", id, new_display_name)

func _on_peer_disconnected(id = 1):
	print("%s disconnected" % id)
  
func reset():
	multiplayer_peer.close_connection()
	multiplayer_peer = ENetMultiplayerPeer.new()
	is_host = false


