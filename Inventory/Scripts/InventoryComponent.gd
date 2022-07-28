class_name InventoryComponent
extends Node


signal moved_item_to_chest(item: Item, count: int)
signal added_item(slot: InventoryItemSlot, item: Item, count: int)
signal removed_item(slot: InventoryItemSlot, item: Item, removed_count: int)
signal equip_item_changed(slot_type: Enums.EEquipmentSlot, 
		from_item_slot: InventoryItemSlot, to_item_slot: InventoryItemSlot)

var _inventory: Array[InventoryItemSlot]
var _equipment: Dictionary = {
	Enums.EEquipmentSlot.L_HAND_1: null,
	Enums.EEquipmentSlot.L_HAND_2: null,
	Enums.EEquipmentSlot.L_HAND_3: null,
	Enums.EEquipmentSlot.R_HAND_1: null,
	Enums.EEquipmentSlot.R_HAND_2: null,
	Enums.EEquipmentSlot.R_HAND_3: null,
	Enums.EEquipmentSlot.HELM: null,
	Enums.EEquipmentSlot.ARMOR: null,
	Enums.EEquipmentSlot.BOOTS: null,
	Enums.EEquipmentSlot.AMULET: null,
	Enums.EEquipmentSlot.CONSUMABLE_1: null,
	Enums.EEquipmentSlot.CONSUMABLE_2: null,
	Enums.EEquipmentSlot.CONSUMABLE_3: null,
	Enums.EEquipmentSlot.CONSUMABLE_4: null,
	Enums.EEquipmentSlot.CONSUMABLE_5: null,
	Enums.EEquipmentSlot.CONSUMABLE_6: null,
}


func add_item(res_path: String, count: int)->InventoryItemSlot:
	var item: Item = load(res_path) as Item
	if (item == null):
		return null
	
	var uid: int = ResourceLoader.get_resource_uid(res_path)
	
	if item.is_consumable():
		var consumable_item: BaseConsumableItem = item
		var slot: InventoryItemSlot = _find_inventory_item_slot(uid)

		if slot == null:
			slot = InventoryItemSlot.new()
			slot.res_uid = uid
			slot.count = 0
			_inventory.append(slot)
		
		var to_chest: int = max(slot.count + count - consumable_item.max_count, 0)
		var to_inventory: int = count - to_chest
		if to_chest > 0:
			emit_signal("moved_item_to_chest", item, to_chest)
		slot.count += to_inventory
		if to_inventory > 0:
			emit_signal("added_item", slot, item, to_inventory)
		return slot
		
	var slot: InventoryItemSlot = null
	for i in range(count):
		slot = InventoryItemSlot.new()
		slot.res_uid = uid
		slot.count = 1
		_inventory.append(slot)
		emit_signal("added_item", slot, item, 1)
	
	return slot


func remove_item(res_path: String, count: int)->bool:
	var item: Item = load(res_path)
	if item == null:
		print("Item Resource ", res_path, " is not loaded!")
		return false
		
	var uid: int = ResourceLoader.get_resource_uid(res_path)
	var slot: InventoryItemSlot = _find_inventory_item_slot(uid)
	if slot == null:
		print("Item ", res_path, " is not found in Inventory")
		return false
	
	if item.is_consumable():
		slot.count = max(slot.count - count, 0)
		if (slot.count == 0):
			_inventory.erase(slot)
	else:
		_inventory.erase(slot)
	
	emit_signal("removed_item", slot, item, count)
	return true


func set_items(items: Array[ItemSlotInfo], remove_all_items: bool)->Array[InventoryItemSlot]:
	if remove_all_items:
		_inventory.clear()
	
	var out_items: Array[InventoryItemSlot]
	for slot_info in items:
		var item_slot: InventoryItemSlot = add_item(slot_info.resource_path, slot_info.count)
		out_items.append(item_slot)
		_inventory.append(item_slot)
		if (slot_info.equipment_slot_type != Enums.EEquipmentSlot.NONE):
			set_equip_item_to_slot(item_slot, slot_info.equipment_slot_type)
	
	return out_items


func set_equip_item(inventory_item_slot: InventoryItemSlot)->bool:
	if inventory_item_slot == null:
		print("set_equip_item - Invalid InventoryItemSlot!")
		return false
	
	var item_type: Enums.EItemType = inventory_item_slot.get_item_info().get_item_type()
	for slot_type in _equipment.keys():
		if (item_type != _get_item_type(slot_type)):
			continue
		
		if (_equipment[slot_type] != null):
			continue
			
		_equipment[slot_type] = inventory_item_slot
		_equipment[slot_type].equipment_slot_type = slot_type
		
		emit_signal("equip_item_changed", slot_type, null, _equipment[slot_type])
		return true
	
	return false


func set_equip_item_to_slot(inventory_item_slot: InventoryItemSlot, 
		equipment_slot: Enums.EEquipmentSlot)->bool:
	if !_equipment.keys().has(equipment_slot):
		print("set_equip_item_to_slot - Slot type ", equipment_slot, " is not found!")
		return false
	
	var prev_slot: InventoryItemSlot = _equipment[equipment_slot]
	if prev_slot == inventory_item_slot:
		print("set_equip_item_to_slot - This item \"", inventory_item_slot.get_item_info().ItemName, 
				"\" was already added!")
		return false
	
	if prev_slot != null:
		clear_equip_slot(prev_slot.equipment_slot_type)
	
	if inventory_item_slot.equipment_slot_type != Enums.EEquipmentSlot.NONE:
		clear_equip_slot(inventory_item_slot.equipment_slot_type)
	
	_equipment[equipment_slot] = inventory_item_slot
	_equipment[equipment_slot].equipment_slot_type = equipment_slot
		
	emit_signal("equip_item_changed", equipment_slot, prev_slot, _equipment[equipment_slot])
	return true


func get_inventory_item_slot_by_element_type(equipment_slot: Enums.EEquipmentSlot)->InventoryItemSlot:
	if !_equipment.keys().has(equipment_slot):
		print("get_inventory_item_slot_by_element_type - Slot type ", equipment_slot, " is not found!")
		return null
	
	return _equipment[equipment_slot]


func get_equipments()->Dictionary:
	return _equipment


func get_inventory_items(item_type: Enums.EItemType)->Array[InventoryItemSlot]:
	var out: Array[InventoryItemSlot]
	for item in _inventory:
		if item.get_item_info().get_item_type() == item_type:
			out.append(item)
	
	return out


func clear_equip_slot(equipment_slot: Enums.EEquipmentSlot)->bool:
	if !_equipment.keys().has(equipment_slot):
		print("clear_equip_slot - Slot type ", equipment_slot, " is not found!")
		return false
		
	var prev_slot: InventoryItemSlot = _equipment[equipment_slot]
	if (prev_slot == null):
		print("clear_equip_slot - Slot already empty!")
		return false
	
	prev_slot.equipment_slot_type = Enums.EEquipmentSlot.NONE
	_equipment[equipment_slot] = null
	
	emit_signal("equip_item_changed", equipment_slot, prev_slot, null)
	return true


func _find_inventory_item_slot(res_uid: int)->InventoryItemSlot:
	for slot in _inventory:
		if slot.res_uid != res_uid:
			continue
		return slot
	
	return null


func _get_item_type(slot_type: Enums.EEquipmentSlot)->Enums.EItemType:
	if (slot_type == Enums.EEquipmentSlot.L_HAND_1 
			or slot_type == Enums.EEquipmentSlot.L_HAND_2 
			or slot_type == Enums.EEquipmentSlot.L_HAND_3 
			or slot_type == Enums.EEquipmentSlot.R_HAND_1 
			or slot_type == Enums.EEquipmentSlot.R_HAND_2 
			or slot_type == Enums.EEquipmentSlot.R_HAND_3):
		return Enums.EItemType.WEAPON
	
	if slot_type == Enums.EItemType.HELM:
		return Enums.EItemType.HELM
	
	if slot_type == Enums.EItemType.ARMOR:
		return Enums.EItemType.ARMOR
	
	if slot_type == Enums.EItemType.BOOTS:
		return Enums.EItemType.BOOTS
	
	if slot_type == Enums.EItemType.AMULET:
		return Enums.EItemType.AMULET
	
	if (slot_type == Enums.EEquipmentSlot.CONSUMABLE_1
			or slot_type == Enums.EEquipmentSlot.CONSUMABLE_2
			or slot_type == Enums.EEquipmentSlot.CONSUMABLE_3
			or slot_type == Enums.EEquipmentSlot.CONSUMABLE_4
			or slot_type == Enums.EEquipmentSlot.CONSUMABLE_5
			or slot_type == Enums.EEquipmentSlot.CONSUMABLE_6):
		return Enums.EItemType.CONSUMABLE
	
	return Enums.EItemType.ITEM
