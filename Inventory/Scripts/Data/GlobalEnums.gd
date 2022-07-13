extends Node

enum EWeaponSubtype {
	Sword,
	Axe,
	Spear,
	Bow,
	Crossbow,
	Shield,
	Fists
}

enum EDamageType {
	Standard = 0,
	Pierce,
	Strike,
	Slash,
	Standard_Pierce,
	Slash_Pierce
}

enum EScalingValue {
	NoScaling = 0,
	E,
	D,
	C,
	B,
	A,
	S
}

enum EItemType {
	Item,
	Weapon,
	Armor,
	Helm,
	Boots,
	Amulet,
	Consumable
}

enum EItemEffectType {
	None = 0,
	MaxHP,
	MaxFP,
	RegenHP,
	MaxEquipLoad
}

enum EEquipmentSlot {
	None = 0,
	LHand1,
	LHand2,
	LHand3,
	RHand1,
	RHand2,
	RHand3,
	Helm,
	Armor,
	Boots,
	Amulet,
	Consumables1,
	Consumables2,
	Consumables3,
	Consumables4,
	Consumables5,
	Consumables6
}
