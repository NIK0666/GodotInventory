class_name Item
extends Resource


@export var item_name: String = ""
@export var weight: float = 0
@export var icon: Texture2D
@export var description: String = ""


func is_consumable()->bool:
	return false


func get_item_type()->Enums.EItemType:
	return Enums.EItemType.Item
