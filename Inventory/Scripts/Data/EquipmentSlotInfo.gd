extends Node

class_name EquipmentSlotInfo

@export var ItemType: Enums.EItemType
@export var ItemSlot: ItemSlotInfo = null
@export var Count: int = 1

func _init(item_type: Enums.EItemType):
	ItemType = item_type
