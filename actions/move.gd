class_name MoveAction extends Action


## The amount to move from the actor's current location.
@export var movement: Vector2i


func perform() -> void:
	actor.location += movement
	super.perform()
	print("%s moved to %s" % [actor.name, actor.location])
