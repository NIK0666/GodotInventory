class_name NoteItem
extends Item

@export var pages: Array[String]
@export var background: Texture2D

func get_item_type():
	return Enums.EItemType.NOTE


func get_type_text()->String:
		return "Note"
