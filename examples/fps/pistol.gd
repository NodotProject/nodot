extends Node3D

@export var magazine_node: Magazine

func _ready():
  magazine_node.connect("discharged", action)
  
func action():
  $AnimationPlayer.play("fire")
