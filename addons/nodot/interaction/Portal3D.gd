#Write by: Z3R0_GT 
#Time: 04/19/23
#Last update: 04/19/23

##Portal3D node
class_name Portal3D extends Area3D

@export_category("Nodes")
##Objective to teleport
@export_node_path("Node3D") var Target
##Objective for teleport
@export_node_path("CharacterBody3D") var Player

##Size of collision area
@export_category("Size collision")
@export var X : float = 3.372
@export var Y : float = 3.821
@export var Z : float = 1

#Get position of "Target" and "Player"
@onready var posPlayer = get_node(Player)
@onready var posTarget = get_node(Target)

#Collision object
var NodeCollision : CollisionShape3D

#Check variable for teleport
var check_node = false

func _ready():
	#---------Collision const----------#
	NodeCollision = CollisionShape3D.new()
	NodeCollision.name = "CollisioArea"
	add_child(NodeCollision)
	
	#Create a CollisionShape
	var CollNode = $CollisioArea
	#Create a Shape for "CollisioArea"
	var Shape = BoxShape3D.new()
	
	#Add size to collision and add the shape
	Shape.size = Vector3(X, Y, Z)
	CollNode.shape = Shape
	
	#---------Connect const----------#
	var call_enter = Callable(self, "body_entered")
	self.connect("body_entered", call_enter)
	
	var call_exit = Callable(self, "body_exited")
	self.connect("body_exited", call_exit)

func _process(delta: float) -> void:
	#Get position of target to teleport
	var Targetpos = Vector3(posTarget.position.x, posTarget.position.y, posTarget.position.z)
	
	if check_node:
		posPlayer.position = Targetpos

##When "player" entered
func body_entered(body):
	if body == posPlayer:
		check_node = true

##When "player" exited
func body_exited(body):
	if body == posPlayer:
		check_node = false