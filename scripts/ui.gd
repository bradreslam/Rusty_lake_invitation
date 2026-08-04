extends CanvasLayer

@onready var slot_1 = $Inventory/VBoxContainer/Item_slot/TextureRect
@onready var slot_2 = $Inventory/VBoxContainer/Item_slot2/TextureRect
@onready var slot_3 = $Inventory/VBoxContainer/Item_slot3/TextureRect
@onready var slot_4 = $Inventory/VBoxContainer/Item_slot4/TextureRect
@onready var slot_5 = $Inventory/VBoxContainer/Item_slot5/TextureRect

@onready var Left = $Left
@onready var Right = $Right
@onready var Forward = $Forward
@onready var Back = $Back

signal move(direction:int)
signal open_menu

var inventory = [null,null,null,null,null]
var held_item = null
var inventory_slots = {}

func _ready():
	inventory_slots = {
		0: slot_1,
		1: slot_2,
		2: slot_3,
		3: slot_4,
		4: slot_5,
	}
	add_item(load("res://Assets/Sprites/blood_drop.png"))

func _on_left_pressed():
	move.emit(3)

func _on_forward_pressed():
	move.emit(0)

func _on_right_pressed():
	move.emit(1)

func _on_back_pressed():
	move.emit(2)

func Open():
	Left.visible = false
	Right.visible = false
	Forward.visible = false
	Back.visible = true
	
func Close():
	Left.visible = true
	Right.visible = true
	Forward.visible = false
	Back.visible = false

func add_item(item:Texture2D):
	var index = 0
	for slot in inventory:
		if slot == null:
			inventory[index] = item
			inventory_slots[index].texture = item
			return
		index += 1

func remove_item(item:Texture2D):
	var index = 0
	for slot in inventory:
		if slot == item:
			slot = null
			inventory_slots[index].texture = null
			return true
		index += 1

func _on_menu_pressed():
	open_menu.emit()

func _on_item_slot_pressed():
	held_item = slot_1.texture

func _on_item_slot_2_pressed():
	held_item = slot_2.texture

func _on_item_slot_3_pressed():
	held_item = slot_3.texture

func _on_item_slot_4_pressed():
	held_item = slot_4.texture

func _on_item_slot_5_pressed():
	held_item = slot_5.texture
