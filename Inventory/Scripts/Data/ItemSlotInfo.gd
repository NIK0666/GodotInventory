extends Node

class_name ItemSlotInfo

@export var ResourcePath: String = ""
@export var Count: int = 1
@export var EquipmentSlotType: Enums.EEquipmentSlot = Enums.EEquipmentSlot.None

func _init(res_path: String, count: int):
	ResourcePath = res_path
	Count = count
