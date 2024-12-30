class_name Bubble extends NinePatchRect


@export var label: RichTextLabel


func speak(speaker_name: String, speech: String) -> void:
	var t = "[font=res://ui/peaberry_mono.woff2]%s[/font]\n[center]%s[/center]"
	label.text = t % [speaker_name, speech]


func initial_tip(turns_left: int, hunter_name: String) -> void:
	var t = "You have [b]{turns} actions[/b] before {hunter}'s first hunt. " + \
		"When you are in the same room as {hunter}, you will die. " + \
		"Time will rewind to when the hunt begins and a remnant will " + \
		"repeat the moves of your previous life. {hunter} will chase " + \
		"the remnant while you avoid her and find Vedal! " + \
		"Talk to NPCs or your dead remnants for clues."
	label.text = t.format({"turns": turns_left, "hunter": hunter_name})


func hunt_tip(hunter_name: String) -> void:
	var t = "The hunt begins! {hunter} can now move diagonally. " + \
		"It's okay for {hunter} to catch you. However, if you move " + \
		"into a room where {hunter} can shoot both you and your remnant, " + \
		"that's a game over!"
	label.text = t.format({"hunter": hunter_name})


func replay_tip(remnant_name: String, hunter_name: String):
	var t = "Ouch! Time has rewinded and both {hunter} and your {rem} " + \
		"now trace their previous steps. Use this knowledge to avoid " + \
		"running into {hunter}. Your {rem} will examine rooms that " + \
		"they've been to. Interact with them later to hear from them!"
	label.text = t.format({"rem": remnant_name, "hunter": hunter_name})


func wander_tip(remnant_name: String, hunter_name: String):
	var t = "{hunter} has caught up to your {rem}. {hunter} will now " + \
		"wander randomly across the map. Find an opportunity to interact " + \
		"with your {rem} to get more clues on finding Vedal."
	label.text = t.format({"rem": remnant_name, "hunter": hunter_name})


func wrong_tip(hunter_name: String):
	var t = "A wrong guess starts a hunt where {hunter} can move " + \
		"diagonally so she will catch you quickly. Perhaps you could " + \
		"lure {hunter} away from points of interest, or die quick to " + \
		"reset your bearings."
	label.text = t.format({"hunter": hunter_name})


func npc_tip(actor_name: String):
	var t = "You've just spoken to %s. Sometimes they have more to say, " + \
		"so multiple interactions may be useful. Refer to your map for " + \
		"clues regarding room aesthetics. Maybe Vedal is there!"
	label.text = t % actor_name
