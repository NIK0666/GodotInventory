class_name ArmorItem
extends BaseUndurableItem

@export var level: int = 1

@export_category(Defence)
@export var physical_defence: float
@export var magic_defence: float
@export var fire_defence: float
@export var ice_defence: float


func get_item_type():
	return Enums.EItemType.ARMOR

func get_type_text()->String:
		return "Armor"
