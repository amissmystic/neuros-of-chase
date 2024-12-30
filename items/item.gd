class_name Item extends Node2D


signal mouse_clicked

## Sprite of the item.
@export var sprite: Sprite2D
## Slightly larger sprite of the item to act as a highlight outline.
@export var outline: Sprite2D
## If true, this item is meant to be hung on a wall and should be elevated.
@export var hanging: bool
## If true, this item can be interacted by the player.
@export var interactable: bool = true
## If true, this item wins the game when the player interacts with it.
@export var is_goal: bool



## When the player interacts with an item, it is an attempt to end the game
## by guessing if Vedal was hidden by Evil in this item.
func interact():
	if interactable and not Definition.in_cutscene:
		mouse_clicked.emit()


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		interact()


func _on_mouse_entered() -> void:
	if interactable and not Definition.in_cutscene:
		outline.show()


func _on_mouse_exited() -> void:
	outline.hide()
