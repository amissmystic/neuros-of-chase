class_name HunterController extends Actor


## Determines on which turn will the hunter AI choose to store the goal.
@export var store_turn: int
## Location where the hunter will spawn for a hunt or replay.
@export var spawn_location: Vector2i
## AnimationPlayer in charge of shooting harpoons.
@export var harpoon_animator: AnimationPlayer

## Stored stagger amount when a replay triggers within a replay.
var replay_stagger: int
## Number of turns to stagger during replay due to player headstart.
var stagger: int


## Called each time a turn needs to be taken during the hunter headstart phase.
func plan(game: ChaseGame) -> Action:
	var abilities: Array[Ability] = get_abilities()
	var actions = []
	for ability in abilities:
		actions += ability.make_actions(game)
	
	# if time to store Vedal, pick a random store location in current room
	# this logic limits the latest turn only, it can still be stored earlier
	var selected: Action = actions[game.randomizer.randi() % actions.size()]
	if actions_taken >= store_turn:
		for action in actions:
			if action is StoreAction:
				selected = action
				break
	
	# carry out the planned action
	var clone = selected.clone()
	selected.perform()
	end_turn()
	return clone


## Called each time a turn needs to be taken during the hunt phase.
func hunt(game: ChaseGame) -> void:
	# focus on moving only, we are chasing Neuro down!
	var movement_abilities: Array[Ability] = get_abilities().filter(
			func(a): return a is OrthogonalMovement or a is DiagonalMovement)
	# define a sorter function to check distance to player
	var sorter = func(a, b): return _distance_to(a, game.player) < _distance_to(b, game.player)
	
	# perform the MoveAction with the shortest distance to the game player
	var chase_actions = []
	for move_ability in movement_abilities:
		chase_actions += move_ability.make_actions(game)
	chase_actions.sort_custom(sorter)
	chase_actions[0].perform()
	replay_actions.append(chase_actions[0].clone())
	end_turn()


func replay() -> bool:
	if stagger > 0:
		stagger -= 1
		return true
	return super.replay()


## Wandering AI behavior. This happens when a remnant is caught and the
## hunter is free to roam the map.
func wander(game: ChaseGame) -> void:
	var abilities: Array[Ability] = get_abilities()
	var actions = []
	for ability in abilities:
		actions += ability.make_actions(game)
	var selected: Action = actions[game.randomizer.randi() % actions.size()]
	selected.perform()
	replay_actions.append(selected.clone())
	end_turn()


func end_turn() -> void:
	for ability in get_abilities():
		ability.clear_actions()


func powerup(enable: bool = true) -> void:
	for ability in get_abilities():
		if ability is DiagonalMovement:
			if enable:
				return
			else:
				ability.free()
	if enable:
		add_child(DiagonalMovement.new())


func _distance_to(move: MoveAction, target: Actor) -> float:
	return (move.movement + location).distance_squared_to(target.location)
