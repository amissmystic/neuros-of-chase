extends Node


@onready var music_player = $MusicPlayer
@onready var sfx_player = $SFXPlayer
@onready var impact_timer = $ImpactTimer

var impact_tween: Tween


func play_sound(stream: AudioStream, pitch: float = 1.0) -> void:
	sfx_player.stream = stream
	sfx_player.pitch_scale = pitch
	sfx_player.play()


## Temporarily mute music player and fade back in.
func impact_music() -> void:
	music_player.volume_db = -80.0
	if impact_tween:
		impact_tween.kill()
	impact_tween = create_tween()
	impact_tween.tween_property(music_player, "volume_db", 0.0, 3.0)
	#impact_timer.start()
	#_on_impact_timeout()


func _on_impact_timeout() -> void:
	if impact_tween:
		impact_tween.kill()
	impact_tween = create_tween()
	impact_tween.tween_property(music_player, "volume_db", 0.0, 3.0)
