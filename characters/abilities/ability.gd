## An [Ability] allows a [Actor] to perform certain [Action]s.
class_name Ability extends Node


## The character that wields this ability. If unassigned, get parent on ready.
@export var wielder: Actor


func _ready() -> void:
	if not wielder:
		wielder = get_parent()


func clear_actions() -> void:
	for child in get_children():
		child.queue_free()


## Create valid actions based on the given game state.
func make_actions(_game: ChaseGame) -> Array[Action]:
	return []
