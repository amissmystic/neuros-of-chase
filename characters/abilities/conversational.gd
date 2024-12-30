class_name Conversational extends Ability


const INPUT_MAP = ["interact_first", "interact_second", "interact_third"]


func make_actions(game: ChaseGame) -> Array[Action]:
	var room: Room = game.board[wielder.location.x][wielder.location.y]
	var list: Array[Action] = []
	
	for npc in room.item_spawner.npcs:
		var action = TalkAction.new()
		action.actor = wielder
		action.input_name = INPUT_MAP[npc.get_index()]
		action.target = npc
		add_child(action)
		npc.mouse_clicked.connect(action.perform)
		list.append(action)
	
	if game.remnant.is_active() and \
			game.remnant.location == wielder.location and \
			game.remnant.replay_progress >= game.remnant.replay_actions.size():
		var action = TalkAction.new()
		action.actor = wielder
		action.input_name = "interact_remnant"
		action.target = game.remnant
		add_child(action)
		game.remnant.mouse_clicked.connect(action.perform)
		list.append(action)
	
	return list
