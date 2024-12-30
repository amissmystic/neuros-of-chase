class_name GoalStorage extends Ability


func make_actions(game: ChaseGame) -> Array[Action]:
	var room: Room = game.board[wielder.location.x][wielder.location.y]
	var list: Array[Action] = []
	
	for item in room.item_spawner.items:
		var action = StoreAction.new()
		action.actor = wielder
		action.storage = item
		action.source = self
		add_child(action)
		list.append(action)
	
	return list
