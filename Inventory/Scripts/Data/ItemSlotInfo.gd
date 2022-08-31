class_name ItemSlotInfo
extends Node


@export var resource_path: String = ""
@export var count: int = 1
@export var equipment_slot_type: Enums.EEquipmentSlot = Enums.EEquipmentSlot.NONE


func _init(res_path: String, count: int = 1, slot_type: Enums.EEquipmentSlot = Enums.EEquipmentSlot.NONE)->void:
	resource_path = res_path
	count = count
	equipment_slot_type = slot_type
