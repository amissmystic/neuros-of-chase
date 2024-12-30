class_name ChaseGame extends Node2D


enum Phase { HUNTER_SETUP, PLAYER_SETUP, HUNT, REPLAY, WANDER }

@export var game_over_scene: PackedScene
@export var room_offset: Vector2i = Vector2i(48, 32)
@export var room_scene: PackedScene
@export var room_map: RoomMap
@export var rewind_timer: Timer
@export var player: PlayerController
@export var player_headstart: int = 3
@export var remnant: RemnantController
@export var hunter: HunterController
@export var hunter_headstart: int = 6
@export var tip_animator: AnimationPlayer
@export var tip_bubble: Bubble
@export var speech_animator: AnimationPlayer
@export var speech_bubble: Bubble
@export var score_label: Label
@export var npc_scenes: Array[PackedScene]

## 2-dimensional array (grid) of Rooms.
var board: Array[Array]
## Current phase of the game which informs how the hunter AI should behave.
var current_phase: Phase
## The room currently displayed.
var current_room: Room
## GameOver instance to set if game should be ending. Null if not ending.
var game_over: GameOver
## List of item PackedScenes that can be used to spawn interactables in rooms.
var item_table: Array
## NPCs to talk to, excluding Remnant.
var npc_list: Array[Actor]
## Available actions for the player to take in the current turn.
var player_actions: Array[Action]
## The RandomNumberGenerator that can take in a seed for the entire game.
var randomizer: RandomNumberGenerator
## Tracks the passing of rounds in the game so that actions can be reversed.
var round_count: int
## True when the game is ready for the player to take a turn action.
var turn_ready: bool
## Number of turns the player is allowed to take before first hunt begins.
var turns_to_first_hunt: int

var hit_sound: AudioStreamWAV = preload("res://sounds/hit.wav")
var negative_sound: AudioStreamWAV = preload("res://sounds/negative.wav")
var walk_sound: AudioStreamWAV = preload("res://sounds/walk.wav")
var whistle_sound: AudioStreamWAV = preload("res://sounds/whistle.wav")
var wipe_sound: AudioStreamWAV = preload("res://sounds/wipe.wav")
var wipe_pitch: float = 1.0

@onready var volume_slider = $VolumeSlider
@onready var fullscreen_button = $FullscreenButton


func _ready() -> void:
	randomizer = RandomNumberGenerator.new()
	reset()
	setup()
	tip_bubble.initial_tip(turns_to_first_hunt + 1, hunter.name)
	tip_animator.play("appear")


func begin_hunt(is_first: bool = false) -> void:
	current_phase = Phase.HUNT
	print("Hunt phase begins, %s can move diagonally" % hunter.name)
	hunter.powerup()
	if is_first:
		hunter.stagger = player_headstart
		hunter.replay_stagger = hunter.stagger
	else:
		hunter.spawn_location = hunter.location
		hunter.rerecord()
		player.rerecord()
		player.previous_locations.append(player.location)


func begin_replay() -> void:
	hunter.location = hunter.spawn_location
	print("%s rewinded to %s" % [hunter.name, hunter.spawn_location])
	print("%s rewinded to %s" % [player.name, player.location])
	tip_bubble.replay_tip(remnant.name, hunter.name)
	tip_animator.play("appear")
	
	if hunter.location == player.location:
		# TODO: GAME OVER
		pass
	
	Definition.in_cutscene = false
	# spawn a remnant at the player's location
	remnant.location = player.location
	remnant.position = current_room.remnant_spawn + room_offset
	remnant.show()
	remnant.alive()
	remnant.ghost_timer.start()
	
	if current_phase == Phase.REPLAY:
		# if a replay was triggered in the middle of another replay,
		# do not wipe the hunter and remnant, just repeat the first replay
		hunter.replay_progress = 0
		hunter.stagger = hunter.replay_stagger
	else:
		remnant.rerecord()
		remnant.replay_actions = player.replay_actions.map(func(x): return x.clone())
		remnant.previous_locations = player.previous_locations
		remnant.reassign_actor()
	
	remnant.replay_progress = 0
	room_map.show_remnant(remnant.location)
	player.rerecord()
	current_phase = Phase.REPLAY
	start_player_turn()


func begin_wander() -> void:
	current_phase = Phase.WANDER
	hunter.powerup(false)
	print("%s can no longer move diagonally" % hunter.name)
	hunter.spawn_location = hunter.location
	hunter.rerecord()
	player.rerecord()
	tip_bubble.wander_tip(remnant.name, hunter.name)
	tip_animator.play("appear")
	Audio.play_sound(whistle_sound)


## Check if hunter and player are in the same location for a kill.
func check_kill() -> bool:
	var same_location = hunter.location == player.location
	var game_on = current_phase > Phase.PLAYER_SETUP
	var unstaggered = current_phase != Phase.REPLAY or hunter.stagger <= 0
	
	if same_location and game_on and unstaggered:
		if remnant.is_active() and hunter.location == remnant.location:
			print("Game ending due to convergence")
			game_over = game_over_scene.instantiate()
			game_over.reason.text = "Reason: Convergence"
			game_over.description.text = \
					"%s must not exist in the same room as %s and %s." % \
					[remnant.name, hunter.name, player.name]
		
		turn_ready = false
		var room: Room = board[hunter.location.x][hunter.location.y]
		hunter.position = room.hunter_spawn + room_offset
		hunter.show()
		hunter.harpoon_animator.play("shoot")
		Definition.in_cutscene = true
		Audio.impact_music()
		return true
	return false


## Called when hunter finishes a kill animation on the player.
func kill_confirmed(_animation_name: String) -> void:
	print("%s was killed by %s" % [player.name, hunter.name])
	hunter.hide()
	remnant.hide()
	
	if game_over:
		get_tree().root.add_child(game_over)
		return
	
	player.rewind_progress = player.previous_locations.size() - 1
	hunter.rewind_progress = hunter.previous_locations.size() - 1
	remnant.rewind_progress = remnant.previous_locations.size() - 1
	wipe_pitch = 1.0  # reset wipe pitch
	rewind_timer.start()


func get_room_product() -> Array:
	var product = []
	for flooring in Room.FLOORING:
		for wall in Room.WALL:
			product.append([flooring, wall])
	return product


func make_room(products: Array, rng: RandomNumberGenerator) -> Room:
	var selected_set = products[rng.randi() % products.size()]
	products.erase(selected_set)
	
	var gacha: Array[PackedScene] = []
	for i in range(ItemSpawner.NUMBER_TO_SPAWN):
		# regenerate items without NPCs if they were exhausted
		if item_table.is_empty():
			item_table = Definition.item_pool.duplicate()
		var item = item_table[rng.randi() % item_table.size()]
		# multiple same items can appear in the same room if the item pool
		# exhausted and replenished, so just skip to avoid duplicate items
		if not gacha.has(item):
			gacha.append(item)
		item_table.erase(item)
	
	var room: Room = room_scene.instantiate()
	room.floor_coordinates = selected_set[0]
	room.wall_coordinates = selected_set[1]
	room.item_spawner.spawn(gacha)
	npc_list += room.item_spawner.npcs
	room.build()
	return room


func reset() -> void:
	round_count = 0
	turns_to_first_hunt = player_headstart - 1
	for node in player_actions:
		if is_instance_valid(node):
			node.queue_free()
	player_actions = []
	
	for row in board:
		for room in row:
			room.queue_free()
	board = []
	npc_list = []
	item_table = Definition.item_pool.duplicate() + npc_scenes
	current_room = null
	current_phase = Phase.HUNTER_SETUP
	room_map.clear()
	turn_ready = false
	randomizer.randomize()
	player.hide()
	hunter.hide()
	remnant.hide()


## Plays the rewind animation for the player.
func rewind() -> void:
	player.location = player.previous_locations[player.rewind_progress]
	update_room()
	Audio.play_sound(wipe_sound, wipe_pitch)
	wipe_pitch += 0.1
	
	if hunter.rewind_progress >= 0:
		room_map.show_evil(hunter.previous_locations[hunter.rewind_progress])
		hunter.rewind_progress -= 1
	if remnant.rewind_progress >= 0:
		room_map.show_remnant(remnant.previous_locations[remnant.rewind_progress])
		remnant.rewind_progress -= 1
	
	player.rewind_progress -= 1
	if player.rewind_progress < 0:
		rewind_timer.stop()
		begin_replay()


## Setup the game board.
func setup(rows: int = 4, columns: int = 4) -> void:
	room_map.columns = columns
	room_map.populate(rows * columns)
	var room_products = get_room_product()
	
	board = []
	board.resize(rows)
	for i in range(rows):
		board[i] = []
		board[i].resize(columns)
		for j in range(columns):
			# regenerate products if they were exhausted in this loop
			if room_products.is_empty():
				room_products = get_room_product()
			board[i][j] = make_room(room_products, randomizer)
	
	# spawn Evil in a random location on the board
	hunter.location = _get_random_location(rows, columns)
	print("%s spawned at %s" % [hunter.name, hunter.location])
	hunter.add_child(OrthogonalMovement.new())
	hunter.add_child(GoalStorage.new())
	
	# determine on which latest turn will the hunter AI choose to store Vedal
	hunter.store_turn = randomizer.randi() % hunter_headstart
	print("%s will set goal latest on turn %d" % [hunter.name, hunter.store_turn + 1])
	
	# simulate Evil's actions for hunter_headstart (default 6) turns
	for i in range(hunter_headstart):
		var before = hunter.location
		var incident = hunter.plan(self)
		var after = hunter.location
		for npc in npc_list:
			npc.record_clue(before, incident, after, hunter.name)
		incident.queue_free()
	
	# populate goal information
	var goal_room: Room = board[Definition.goal_location.x][Definition.goal_location.y]
	Definition.goal_floor_desc = goal_room.FLOORING.get(goal_room.floor_coordinates)
	Definition.goal_wall_desc = goal_room.WALL.get(goal_room.wall_coordinates)
	for npc in npc_list:
		npc.prophesize_clue(randomizer)
	
	# relocate Evil to a random location
	hunter.location = _get_random_location(rows, columns)
	hunter.spawn_location = hunter.location
	room_map.show_evil(hunter.location)
	print("%s disappeared and will reappear at %s" % [hunter.name, hunter.location])
	
	# spawn Neuro player in a random location, must be different from hunter
	player.location = _get_random_location(rows, columns)
	while player.location == hunter.location:
		player.location = _get_random_location(rows, columns)
	print("%s spawned at %s" % [player.name, player.location])
	player.add_child(OrthogonalMovement.new())
	player.add_child(GoalSearching.new())
	player.add_child(Conversational.new())
	update_room()
	
	# start the game, give Neuro 3 turns before the hunt begins
	current_phase = Phase.PLAYER_SETUP
	start_player_turn()


## Starts the turn for the player.
func start_player_turn() -> void:
	turn_ready = true
	player.previous_locations.append(player.location)
	# generate list of actions for player
	for ability in player.get_abilities():
		player_actions += ability.make_actions(self)
	for action in player_actions:
		action.performed.connect(player_turn_taken)


## Called when an action is performed by the player.
func player_turn_taken(action: Action) -> void:
	turn_ready = false
	score_label.text = "Actions Taken: %d" % player.actions_taken
	for old_action in player_actions:
		old_action.queue_free()
	player_actions = []
	
	if action is MoveAction:
		Audio.play_sound(walk_sound)
	
	# check win condition
	if action is SearchAction:
		if action.target.is_goal:
			# win condition found, end game in victory
			print("Goal found, player has won")
			game_over = game_over_scene.instantiate()
			game_over.is_victory = true
			game_over.show_victory(action.target, player.location)
			get_tree().root.add_child(game_over)
			return
		else:
			# punish the player for wrong guess
			begin_hunt()
			Audio.play_sound(negative_sound)
			tip_bubble.wrong_tip(hunter.name)
			tip_animator.play("appear")
			
			
	player.replay_actions.append(action.clone())
	if is_instance_valid(action):
		action.queue_free()
	
	# show clue
	if action is TalkAction:
		speech_bubble.speak(action.target.name, action.target.tell_clue())
		speech_animator.play("appear")
		Audio.play_sound(hit_sound)
		tip_bubble.npc_tip(action.target.name)
		tip_animator.play("appear")
	
	# do remnant's turn first before checking hunter
	if current_phase == Phase.REPLAY:
		remnant.replay()
		room_map.show_remnant(remnant.location)
	update_room()
	
	if check_kill():
		return
	
	# hunter reacts to player's turn
	hunter.previous_locations.append(hunter.location)
	match current_phase:
		Phase.PLAYER_SETUP:
			if turns_to_first_hunt > 0:
				turns_to_first_hunt -= 1
				tip_bubble.initial_tip(turns_to_first_hunt + 1, hunter.name)
				tip_animator.play("appear")
			else:
				begin_hunt(true)  # start the first hunt phase
				print("%s spawns at %s" % [hunter.name, hunter.spawn_location])
				if hunter.location == player.location:
					hunter.stagger += 1
					hunter.replay_stagger = hunter.stagger
				
				tip_bubble.hunt_tip(hunter.name)
				tip_animator.play("appear")
				Audio.play_sound(negative_sound)
		
		Phase.HUNT:
			hunter.hunt(self)
		
		Phase.REPLAY:
			hunter.replay()
			if remnant.replay_progress >= remnant.replay_actions.size():
				# replay is over, time to wander
				begin_wander()
		
		Phase.WANDER:
			hunter.wander(self)
	
	room_map.show_evil(hunter.location)
	
	if not check_kill():
		start_player_turn()


## Update room state to reflect where the player currently is.
func update_room() -> void:
	if current_room:
		remove_child(current_room)
	var room: Room = board[player.location.x][player.location.y]
	add_child(room)
	
	var back = player.location
	if player.previous_locations.size() > 0:
		back = player.previous_locations[-1]
	var previous_direction = player.location - back
	var room_stagger = previous_direction * Vector2i(64, 48)
	room.position = room_offset + room_stagger
	room.modulate.a = 0
	current_room = room
	
	var player_stagger = previous_direction * Vector2i(16, 16)
	player.position = room.player_spawn + room_offset - player_stagger
	player.show()
	room_map.reveal(player.location, room)
	if remnant.is_active() and remnant.location == player.location:
		remnant.show()
	else:
		remnant.hide()
	
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(room, "position", Vector2(room_offset), 0.1)
	tween.tween_property(room, "modulate:a", 1.0, 0.1)
	tween.tween_property(player, "position", Vector2(room.player_spawn + room_offset), 0.1)


func _get_random_location(rows: int, columns: int) -> Vector2i:
	return Vector2i(randomizer.randi() % rows, randomizer.randi() % columns)


func _on_volume_slider_changed(value: float) -> void:
	if value <= volume_slider.min_value:
		AudioServer.set_bus_mute(0, true)
	else:
		AudioServer.set_bus_mute(0, false)
		AudioServer.set_bus_volume_db(0, value)


func _on_fullscreen_button_pressed() -> void:
	if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
