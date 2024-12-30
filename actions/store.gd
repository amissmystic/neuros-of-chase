class_name StoreAction extends Action


## The item that will become the goal item.
@export var storage: Item
## The ability that will be freed once this action is performed.
@export var source: Ability


func perform() -> void:
	storage.is_goal = true
	super.perform()
	print("Goal was stored in %s at %s" % [storage.name, actor.location])
	Definition.goal_location = actor.location
	Definition.goal_item_desc = storage.name
	source.free()  # free the ability that created this action
