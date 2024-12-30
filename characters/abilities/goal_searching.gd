class_name GoalSearching extends Ability


const INPUT_MAP = ["interact_first", "interact_second", "interact_third"]


func make_actions(game: ChaseGame) -> Array[Action]:
	var room: Room = game.board[wielder.location.x][wielder.location.y]
	var list: Array[Action] = []
	
	for item in room.item_spawner.items:
		var action = SearchAction.new()
		action.actor = wielder
		action.input_name = INPUT_MAP[item.get_index()]
		action.target = item
		add_child(action)
		item.mouse_clicked.connect(action.perform)
		list.append(action)
	
	return list
