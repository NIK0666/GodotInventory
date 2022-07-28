class_name WeaponItem
extends Item


@export var stamina_cost: float


func get_item_type():
	return Enums.EItemType.WEAPON
