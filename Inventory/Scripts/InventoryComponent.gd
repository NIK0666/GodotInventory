extends Node

class_name InventoryComponent
var Inventory: Array[InventoryItemSlot]
var Equipment: Dictionary

signal MoveItemToChest(res_path: String, item: Item, count: int)
signal AddedItemEvent(res_path: String, item: Item, count: int, total_count: int)
signal RemovedItemEvent(res_path: String, item: Item, removed_count: int, total_count: int)
signal EquipItemChanged(slot_type: Enums.EEquipmentSlot, from_item_slot: InventoryItemSlot, to_item_slot: InventoryItemSlot)

func _init():
	Equipment[Enums.EEquipmentSlot.LHand1] = null
	Equipment[Enums.EEquipmentSlot.LHand2] = null
	Equipment[Enums.EEquipmentSlot.LHand3] = null
	Equipment[Enums.EEquipmentSlot.RHand1] = null
	Equipment[Enums.EEquipmentSlot.RHand2] = null
	Equipment[Enums.EEquipmentSlot.RHand3] = null
	Equipment[Enums.EEquipmentSlot.Helm] = null
	Equipment[Enums.EEquipmentSlot.Armor] = null
	Equipment[Enums.EEquipmentSlot.Boots] = null
	Equipment[Enums.EEquipmentSlot.Amulet] = null
	Equipment[Enums.EEquipmentSlot.Consumables1] = null
	Equipment[Enums.EEquipmentSlot.Consumables2] = null
	Equipment[Enums.EEquipmentSlot.Consumables3] = null
	Equipment[Enums.EEquipmentSlot.Consumables4] = null
	Equipment[Enums.EEquipmentSlot.Consumables5] = null
	Equipment[Enums.EEquipmentSlot.Consumables6] = null


func AddItem(res_path: String, count: int)->InventoryItemSlot:
	var item: Item = load(res_path)
	if (item == null):
		return null
	
	if (item.IsConsumable()):
		var consumable_item:BaseConsumableItem = item
		var slot: InventoryItemSlot = FindInventoryItemSlot(res_path)

		if (slot == null):
			slot = InventoryItemSlot.new()
			slot.ResourcePath = res_path
			slot.Count = 0
			Inventory.append(slot)

		var to_chest: int = max(slot.Count + count - consumable_item.MaxCount, 0)
		var to_inventory: int = count - to_chest
		if to_chest > 0:
			emit_signal("MoveItemToChest", res_path, item, to_chest)
		slot.Count += to_inventory
		if to_inventory > 0:
			emit_signal("AddedItemEvent", res_path, item, to_inventory, slot.Count)
		return slot
	
	var slot: InventoryItemSlot = null
	for i in range(count):
		slot = InventoryItemSlot.new()
		slot.ResourcePath = res_path
		slot.Count = 1
		Inventory.append(slot)
		emit_signal("AddedItemEvent", res_path, item, 1, 1)
	
	return slot


func RemoveItem(res_path: String, count: int)->bool:
	var item: Item = load(res_path)
	if (item == null):
		print("Item Resource ", res_path, " is not loaded!")
		return false
	var slot: InventoryItemSlot = FindInventoryItemSlot(res_path)
	if (slot == null):
		print("Item ", res_path, " is not found in Inventory")
		return false
	if (item.IsConsumable()):
		slot.Count = max(slot.Count - count, 0)
		if (slot.Count == 0):
			Inventory.erase(slot)
	else:
		Inventory.erase(slot)	
	emit_signal("RemovedItemEvent", res_path, item, count, slot.Count)
	return true


func SetItems(items: Array[ItemSlotInfo], remove_all_items: bool):
	if (remove_all_items):
		Inventory.clear()
	var out_items: Array[InventoryItemSlot]
	for slot_info in items:
		var item_slot = AddItem(slot_info.ResourcePath, slot_info.Count)
		out_items.append(item_slot)
		Inventory.append(item_slot)
		if (slot_info.EquipmentSlotType != Enums.EEquipmentSlot.None):
			SetEquipItemToSlot(item_slot, slot_info.EquipmentSlotType)
	return out_items


func SetEquipItem(inventory_item_slot: InventoryItemSlot)->bool:
	if (inventory_item_slot == null):
		print("SetEquipItem - Invalid InventoryItemSlot!")
		return false
	
	var item_type = inventory_item_slot.GetItemInfo().GetItemType()
	for slot_type in Equipment.keys():
		var slot_item_type = GetItemType(slot_type)
		if (item_type != slot_item_type):
			continue
		
		if (Equipment[slot_type] != null):
			continue
			
		Equipment[slot_type] = inventory_item_slot
		Equipment[slot_type].EquipmentSlotType = slot_type
		
		emit_signal("EquipItemChanged", slot_type, null, Equipment[slot_type])
		return true
	
	return false


func SetEquipItemToSlot(inventory_item_slot: InventoryItemSlot, equipment_slot: Enums.EEquipmentSlot)->bool:
	if (!Equipment.keys().has(equipment_slot)):
		print("SetEquipItemToSlot - Slot type ", equipment_slot, " is not found!")
		return false
	
	var prev_slot = Equipment[equipment_slot]
	if (prev_slot == inventory_item_slot):
		print("SetEquipItemToSlot - This item \"", inventory_item_slot.GetItemInfo().ItemName, "\" was already added!")
		return false
	if (prev_slot != null):
		ClearEquipSlot(prev_slot.EquipmentSlotType)
	
	if (inventory_item_slot.EquipmentSlotType != Enums.EEquipmentSlot.None):
		print("TODO: ClearEquipSlot")
		ClearEquipSlot(inventory_item_slot.EquipmentSlotType)
	
	Equipment[equipment_slot] = inventory_item_slot
	Equipment[equipment_slot].EquipmentSlotType = equipment_slot
		
	emit_signal("EquipItemChanged", equipment_slot, prev_slot, Equipment[equipment_slot])
	return true


func ClearEquipSlot(equipment_slot: Enums.EEquipmentSlot)->bool:
	if (!Equipment.keys().has(equipment_slot)):
		print("ClearEquipSlot - Slot type ", equipment_slot, " is not found!")
		return false
		
	var prev_slot = Equipment[equipment_slot]
	if (prev_slot == null):
		print("ClearEquipSlot - Slot already empty!")
		return false
	
	prev_slot.EquipmentSlotType = Enums.EEquipmentSlot.None
	Equipment[equipment_slot] = null
	
	emit_signal("EquipItemChanged", equipment_slot, prev_slot, null)
	return true


func GetInventoryItemSlotByEquipmentType(equipment_slot: Enums.EEquipmentSlot)->InventoryItemSlot:
	if (!Equipment.keys().has(equipment_slot)):
		print("GetInventoryItemSlotByEquipmentType - Slot type ", equipment_slot, " is not found!")
		return null
	return Equipment[equipment_slot]


func GetEquipments()->Dictionary:
	return Equipment


func GetInventoryItems(item_type: Enums.EItemType)->Array[InventoryItemSlot]:
	var out: Array[InventoryItemSlot]
	for item in Inventory:
		if item.GetItemInfo().GetItemType() == item_type:
			out.append(item)
	return out


func FindInventoryItemSlot(res_path: String)->InventoryItemSlot:
	for Slot in Inventory:
		if Slot.ResourcePath != res_path:
			continue
		return Slot
	return null


func GetItemType(slot_type: Enums.EEquipmentSlot):
	if (slot_type == Enums.EEquipmentSlot.LHand1 || slot_type == Enums.EEquipmentSlot.LHand2 || slot_type == Enums.EEquipmentSlot.LHand3 ||
	slot_type == Enums.EEquipmentSlot.RHand1 || slot_type == Enums.EEquipmentSlot.RHand2 || slot_type == Enums.EEquipmentSlot.RHand3):
		return Enums.EItemType.Weapon
	if (slot_type == Enums.EItemType.Helm):
		return Enums.EItemType.Helm
	if (slot_type == Enums.EItemType.Armor):
		return Enums.EItemType.Armor
	if (slot_type == Enums.EItemType.Boots):
		return Enums.EItemType.Boots
	if (slot_type == Enums.EItemType.Amulet):
		return Enums.EItemType.Amulet
	if (slot_type == Enums.EEquipmentSlot.Consumables1 || slot_type == Enums.EEquipmentSlot.Consumables2 ||
	slot_type == Enums.EEquipmentSlot.Consumables3 || slot_type == Enums.EEquipmentSlot.Consumables4 ||
	slot_type == Enums.EEquipmentSlot.Consumables5 || slot_type == Enums.EEquipmentSlot.Consumables6):
		return Enums.EItemType.Consumable
	
	return Enums.EItemType.Item
