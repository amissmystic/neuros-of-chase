class_name Room extends Node2D


## Dictionary of floor tile atlas coordinates to their description.
const FLOORING = {
	Vector2i(0, 0): "red shingle",
	Vector2i(0, 1): "checkered",
	Vector2i(1, 0): "wooden",
	Vector2i(1, 1): "marble",
}
## Dictionary of wall tile atlas coordinates to their description.
const WALL = {
	Vector2i(0, 2): "striped",
	Vector2i(0, 3): "squiggly",
	Vector2i(1, 2): "plain",
	Vector2i(1, 3): "cement",
}

## Atlas coordinates for the floor of this room.
@export var floor_coordinates: Vector2i = Vector2i(1, 0)
## Number of rows to generate for the floor tiles.
@export var floor_height: int = 3
## Atlas coordinates for the wall of this room.
@export var wall_coordinates: Vector2i = Vector2i(0, 2)
## Number of rows to generate for the wall tiles.
@export var wall_height: int = 5
## Number of columns to generate for the floor and wall tiles.
@export var tile_length: int = 7
## TileMapLayer node that will be used to generate the floor and wall tiles.
@export var tilemap_layer: TileMapLayer
## Position to place the player if they are in the room.
@export var player_spawn: Vector2i = Vector2i(160, 100)
## Position to place the remnant if they are in the room.
@export var remnant_spawn: Vector2i = Vector2i(128, 100)
## Position to place the hunter if they are in the room.
@export var hunter_spawn: Vector2i = Vector2i(64, 100)
## ItemSpawner node that will place interactable items/NPCs in the room.
@export var item_spawner: ItemSpawner


func _ready():
	build()


func build(remove_corners: bool = true) -> void:
	var height = floor_height + wall_height
	for i in range(height):
		var atlas = wall_coordinates if i < wall_height else floor_coordinates
		
		for j in range(tile_length):
			if remove_corners:
				var c1 = i == 0 and j == 0
				var c2 = i == 0 and j == tile_length - 1
				var c3 = i == height - 1 and j == 0
				var c4 = i == height - 1 and j == tile_length - 1
				if c1 or c2 or c3 or c4:
					continue
			tilemap_layer.set_cell(Vector2i(j, i), 0, atlas)
