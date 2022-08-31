class_name EquipSlotUI
extends BaseSlotUI

@export var placeholder_texture: Texture2D
@export var slot_type: Enums.EEquipmentSlot

@onready var placeholder_icon: TextureRect = get_node("PlaceholderTextureRect")
@onready var active_background: NinePatchRect = get_node("ActiveNinePathRect")

func _ready():
	super._ready()
	placeholder_icon.texture = placeholder_texture

func set_active(value: bool):
	active_background.visible = value
