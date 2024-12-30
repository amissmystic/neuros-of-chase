class_name ItemSpawner extends Node2D


const NUMBER_TO_SPAWN = 3

@export var minimum_x: float = 24
@export var maximum_x: float = 200
@export var normal_height: float = 72
@export var hanging_height: float = 48

var items: Array[Item]
var npcs: Array[Actor]


func spawn(scenes: Array[PackedScene]) -> void:
	var difference = maximum_x - minimum_x
	for i in range(scenes.size()):
		# interactable can be Item or NPC (Actor)
		var interactable: Node2D = scenes[i].instantiate()
		add_child(interactable)
		interactable.position.x = minimum_x + (i * difference / scenes.size())
		
		var hang = interactable.hanging if "hanging" in interactable else false
		interactable.position.y = hanging_height if hang else normal_height
		
		if interactable is Item:
			items.append(interactable)
		elif interactable is Actor:
			npcs.append(interactable)
