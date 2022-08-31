class_name BaseConsumableItem
extends BaseStackableItem


func get_item_type()->int: #Enums.EItemType:
	return Enums.EItemType.CONSUMABLE

func get_type_text()->String:
		return "Consumable"
