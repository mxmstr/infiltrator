extends Node

onready var inventory = get_node_or_null('../Inventory')
onready var next = get_node_or_null('../InvNextInput')
onready var prev = get_node_or_null('../InvPrevInput')


func _ready():
	
	next.connect('just_activated', inventory, '_next', [true])
	prev.connect('just_activated', inventory, '_next', [false])
