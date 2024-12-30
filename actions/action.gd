class_name Action extends Node


## Signal emitted when the action is performed by a performer.
signal performed(action: Action)

## The actor who is performing this action.
@export var actor: Actor
## The name of the event input to trigger this action.
@export var input_name: String


func _input(event: InputEvent) -> void:
	if input_name and event.is_action_pressed(input_name):
		perform()


## Clone the action but discard the input_name for replay purposes.
## Remember to free the Action that was cloned!
func clone() -> Action:
	var another = duplicate()
	another.input_name = ""
	return another


## Trigger the action.
func perform() -> void:
	actor.actions_taken += 1
	performed.emit(self)
