class_name RemnantController extends Actor


@export var ghost_distance: Vector2 = Vector2(16, 16)
@export var ghost_timer: Timer


func alive() -> void:
	eyes.play("default")
	sprite.play("default")
	interactable = false
	clues.clear()


func dead() -> void:
	eyes.play("death")
	sprite.play("attention")
	interactable = true
	
	if previous_locations.has(Definition.goal_location):
		clues.append("I sensed Vedal during my journey.")
		clues.append("I saw %s flooring." % Definition.goal_floor_desc)
		clues.append("Walls were %s." % Definition.goal_wall_desc)
		clues.append("He's in a %s!" % Definition.goal_item_desc)


## Create a tween that animates the remnant moving towards a direction.
func ghost() -> void:
	var rest_position = position
	var indication = Vector2.ZERO
	if not replay_actions.is_empty() and replay_progress >= 0 and \
			replay_progress < replay_actions.size():
		var action = replay_actions[replay_progress]
		if action is MoveAction:
			indication = Vector2(action.movement) * ghost_distance
	
	var tween = create_tween()
	tween.tween_property(self, "position", rest_position + indication, 0.6)
	tween.parallel().tween_property(self, "modulate:a", 0.5, 0.6)
	tween.tween_property(self, "position", rest_position, 0.1)
	tween.parallel().tween_property(self, "modulate:a", 1.0, 0.1)


## Remnants are only active after the player dies once, where the ghost timer
## is then activated and will tick forever.
func is_active() -> bool:
	return not ghost_timer.is_stopped()


## Reassign replay_actions' actor to the remnant.
func reassign_actor() -> void:
	for action in replay_actions:
		action.actor = self


func replay() -> bool:
	var result = super.replay()
	if replay_progress >= replay_actions.size():
		dead()  # the replay has just ended, play some animations
	return result
