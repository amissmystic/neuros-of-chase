## Represents a character that has the [Ability] to interact in the game board.
## NPCs use this class. Controllable characters inherit from this class.
class_name Actor extends Node2D


signal mouse_clicked

@export var sprite: AnimatedSprite2D
@export var eyes: AnimatedSprite2D
@export var outline: AnimatedSprite2D
@export var location: Vector2i
@export var interactable: bool

## Keeps track of the number of actions taken for this actor.
var actions_taken: int
## Actions to perform during the replay phase.
var replay_actions: Array = []
## Index being cycled during replay actions.
var replay_progress: int

## List of locations this player has visited in this life.
var previous_locations: Array[Vector2i] = []
## The rewind progress when killed. Starts from previous_locations.size() - 1.
var rewind_progress: int

## Clues that this actor picked up about the goal.
var clues: Array = []
## Current clue cycle.
var clue_index: int


func get_abilities() -> Array[Ability]:
	var abilities: Array[Ability] = []
	for child in get_children():
		if child is Ability:
			abilities.append(child)
	return abilities


func interact() -> void:
	if interactable and not Definition.in_cutscene:
		mouse_clicked.emit()


func prophesize_clue(rng: RandomNumberGenerator) -> void:
	var roll = rng.randi() % 5
	match roll:
		1:
			var c = "I heard she hid Vedal in a room with %s floor." % Definition.goal_floor_desc
			clues.append(c)
		2:
			var c = "I heard she hid Vedal in a room with %s walls." % Definition.goal_wall_desc
			clues.append(c)
		3:
			var c = "I heard she hid Vedal in a %s." % Definition.goal_item_desc
			clues.append(c)
		_:
			return


## Record an observation of the hunter during the pre-planning phase.
func record_clue(before: Vector2i, incident: Action, after: Vector2i,
		hunter_name: String):
	if incident is MoveAction:
		var wow = "without" if Definition.goal_item_desc else "with"
		if after == location:
			var clue = "%s entered this room from %s %s Vedal." % \
					[hunter_name, _get_direction_string(after, before), wow]
			clues.append(clue)
		elif before == location:
			var clue = "%s went %s from here %s Vedal." % \
					[hunter_name, _get_direction_string(before, after), wow]
			clues.append(clue)


func tell_clue() -> String:
	if clues.is_empty():
		return "I have no idea where Vedal is."
	elif clue_index >= clues.size():
		clue_index = 0
		return "That's all I know."
	else:
		var clue = clues[clue_index]
		clue_index += 1
		return clue


## Returns false if replay has ended, otherwise perform replay actions.
func replay() -> bool:
	if replay_progress < replay_actions.size():
		replay_actions[replay_progress].perform()
		replay_progress += 1
		return true
	return false


## Make a fresh slate for recording replays.
func rerecord() -> void:
	for action in replay_actions:
		action.queue_free()
	replay_actions = []
	replay_progress = 0
	previous_locations = []


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		interact()


func _on_mouse_entered() -> void:
	if interactable and not Definition.in_cutscene:
		outline.show()


func _on_mouse_exited() -> void:
	outline.hide()


func _get_direction_string(from: Vector2i, to: Vector2i) -> String:
	var from_v = Vector2(from)
	var to_v = Vector2(to)
	
	match from_v.direction_to(to_v):
		Vector2.UP: return "North"
		Vector2.DOWN: return "South"
		Vector2.LEFT: return "West"
		Vector2.RIGHT: return "East"
		_: return "somewhere"
