extends Control

@onready var inv: InventoryComponent = get_node("Inventory")

func _ready():
	inv.AddItem("res://Inventory/Data/Consumables/Apple.tres", 1)
	inv.AddItem("res://Inventory/Data/Consumables/Apple.tres", 1)

