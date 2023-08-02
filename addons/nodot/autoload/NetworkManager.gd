extends Node

var enabled = false
var is_host = false

signal host_started(id: int)
signal peer_connected(id: int)

var multiplayer_peer = ENetMultiplayerPeer.new()

func join(address: String, port: int):
	multiplayer_peer.create_client(address, port)
	multiplayer.multiplayer_peer = multiplayer_peer

func host(port: int):
	is_host = true
	multiplayer_peer.create_server(port)
	multiplayer.multiplayer_peer = multiplayer_peer
	multiplayer_peer.peer_connected.connect(_on_peer_connected)
	multiplayer_peer.peer_disconnected.connect(_on_peer_disconnected)
	emit_signal("host_started", multiplayer.get_unique_id())

func _on_peer_connected(id = 1):
	print("%s connected" % id)
	emit_signal("peer_connected", id)

func _on_peer_disconnected(id = 1):
	print("%s disconnected" % id)
  
func reset():
	multiplayer_peer.close_connection()
	multiplayer_peer = ENetMultiplayerPeer.new()
	is_host = false


