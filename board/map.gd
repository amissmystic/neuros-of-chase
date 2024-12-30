class_name RoomMap extends GridContainer


## Map grid square.
@export var square_scene: PackedScene = preload("res://board/square.tscn")

## Last known Evil position.
var last_evil: Vector2i
## Last known remnant position.
var last_remnant: Vector2i
## Last visited location.
var last_visit: Vector2i


func clear() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()


func get_square(location: Vector2i) -> RoomSquare:
	var previous = location.x + location.y * columns
	return get_child(previous)


func populate(count: int) -> void:
	clear()
	for i in range(count):
		var square = square_scene.instantiate()
		add_child(square)


func reveal(location: Vector2i, room: Room) -> void:
	var old_square = get_square(last_visit)
	old_square.neuro_block.hide()
	old_square.highlight(false)
		
	var square = get_square(location)
	square.floor_coordinates = room.floor_coordinates
	square.wall_coordinates = room.wall_coordinates
	square.mark()
	square.neuro_block.show()
	square.highlight(true)
	last_visit = location


func show_evil(location: Vector2i) -> void:
	get_square(last_evil).evil_block.hide()
	get_square(location).evil_block.show()
	last_evil = location


func show_remnant(location: Vector2i) -> void:
	get_square(last_remnant).remnant_block.hide()
	get_square(location).remnant_block.show()
	last_remnant = location
