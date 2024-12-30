extends Node


var goal_location: Vector2i
var goal_floor_desc: String
var goal_wall_desc: String
var goal_item_desc: String

var in_cutscene: bool = false


# item definition
var balloon = preload("res://items/balloon.tscn")
var chair = preload("res://items/chair.tscn")
var chest = preload("res://items/chest.tscn")
var dresser = preload("res://items/dresser.tscn")
var lamp = preload("res://items/lamp.tscn")
var painting_anny = preload("res://items/painting_anny.tscn")
var potted_plant = preload("res://items/potted_plant.tscn")
var safe = preload("res://items/safe.tscn")

var item_pool: Array[PackedScene] = [
	chest, dresser, painting_anny, potted_plant,
	balloon, chair, lamp, safe,
]
