class_name OrthogonalMovement extends Ability


func make_actions(game: ChaseGame) -> Array[Action]:
	var list: Array[Action] = []
	
	if wielder.location.y - 1 >= 0:
		list.append(make_move(Vector2i.UP, "move_up"))
	if wielder.location.y + 1 < game.board.size():
		list.append(make_move(Vector2i.DOWN, "move_down"))
	if wielder.location.x - 1 >= 0:
		list.append(make_move(Vector2i.LEFT, "move_left"))
	if wielder.location.x + 1 < game.board[wielder.location.x].size():
		list.append(make_move(Vector2i.RIGHT, "move_right"))
	
	return list


func make_move(vector: Vector2i, input_name: String) -> MoveAction:
	var move = MoveAction.new()
	move.actor = wielder
	move.input_name = input_name
	move.movement = vector
	add_child(move)
	return move
