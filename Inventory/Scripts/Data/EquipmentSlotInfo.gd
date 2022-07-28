class_name EquipmentSlotInfo
extends Node


var item_type: Enums.EItemType
var item_slot: ItemSlotInfo = null
var count: int = 1


func _init(item_type: Enums.EItemType):
	self.item_type = item_type
