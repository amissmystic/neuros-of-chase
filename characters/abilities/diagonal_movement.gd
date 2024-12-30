class_name DiagonalMovement extends Ability


func make_actions(game: ChaseGame) -> Array[Action]:
	var list: Array[Action] = []
	
	var left_check = wielder.location.x - 1 >= 0
	var right_check = wielder.location.x + 1 < game.board[wielder.location.x].size()
	var up_check = wielder.location.y - 1 >= 0
	var down_check = wielder.location.y + 1 < game.board.size()
	
	if up_check and left_check:
		list.append(make_move(Vector2i(-1, -1)))  # top-left
	if up_check and right_check:
		list.append(make_move(Vector2i(1, -1))) # top-right
	if down_check and left_check:
		list.append(make_move(Vector2i(-1, 1))) # bottom-left
	if down_check and right_check:
		list.append(make_move(Vector2i(1, 1))) # bottom-right
	
	return list


func make_move(vector: Vector2i) -> MoveAction:
	var move = MoveAction.new()
	move.actor = wielder
	move.movement = vector
	add_child(move)
	return move
