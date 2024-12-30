class_name GameOver extends Control


## Main message.
@export var message: Label
## Reason the player won.
@export var reason: Label
## Better explanation on why the player won.
@export var description: Label
## Mark this screen as victory. Used to buffer the screen to show after events.
@export var is_victory: bool
@export var new_game_button: Button

var bad_sound: AudioStreamWAV = preload("res://sounds/warning.wav")
var good_sound: AudioStreamWAV = preload("res://sounds/positive.wav")


func _ready() -> void:
	Audio.play_sound(good_sound if is_victory else bad_sound)


func show_victory(goal: Item, location: Vector2i):
	message.text = "You Win"
	reason.text = "Thanks for playing!"
	description.text = "Evil hid Vedal in a %s at %s and you found him!" % \
			[goal.name, location]
	$Tutel.show()


func new_game() -> void:
	Definition.in_cutscene = false
	queue_free()
	get_tree().reload_current_scene()
