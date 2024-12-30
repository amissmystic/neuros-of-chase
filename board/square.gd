class_name RoomSquare extends PanelContainer

const HEIGHT = 16
const WIDTH = 32

@export var floor_coordinates: Vector2i = Vector2i(1, 0)
@export var wall_coordinates: Vector2i = Vector2i(0, 2)
@export var floor_rect: TextureRect
@export var wall_rect: TextureRect
@export var neuro_block: TextureRect
@export var remnant_block: TextureRect
@export var evil_block: TextureRect
@export var unknown_rect: ColorRect

var texture = preload("res://board/tiles/starter/atlas.png")
var default = preload("res://ui/square.stylebox")
var highlighted = preload("res://ui/square_highlight.stylebox")


## Mark this square as visited.
func mark() -> void:
	var wall_width = wall_coordinates.x * WIDTH
	var wall_height = wall_coordinates.y * HEIGHT
	var wall_texture = AtlasTexture.new()
	wall_texture.atlas = texture
	wall_texture.region = Rect2(wall_width, wall_height, WIDTH, HEIGHT)
	wall_rect.texture = wall_texture
	
	var floor_width = floor_coordinates.x * WIDTH
	var floor_height = floor_coordinates.y * HEIGHT
	var floor_texture = AtlasTexture.new()
	floor_texture.atlas = texture
	floor_texture.region = Rect2(floor_width, floor_height, WIDTH, HEIGHT)
	floor_rect.texture = floor_texture
	
	unknown_rect.hide()


func highlight(enabled: bool) -> void:
	add_theme_stylebox_override("panel", highlighted if enabled else default)
