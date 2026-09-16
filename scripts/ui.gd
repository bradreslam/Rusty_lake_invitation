extends CanvasLayer

@export var button_group:ButtonGroup

@onready var container = $Inventory/VBoxContainer
@onready var slot_1 = $Inventory/VBoxContainer/Item_slot/TextureRect
@onready var slot_2 = $Inventory/VBoxContainer/Item_slot2/TextureRect
@onready var slot_3 = $Inventory/VBoxContainer/Item_slot3/TextureRect
@onready var slot_4 = $Inventory/VBoxContainer/Item_slot4/TextureRect
@onready var slot_5 = $Inventory/VBoxContainer/Item_slot5/TextureRect
@onready var description = $Label
@onready var transition = $ColorRect

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
	for slot in inventory_slots:
		var par:TextureButton = inventory_slots[slot].get_parent()
		par.connect("mouse_entered",open_discription.bind(inventory_slots[slot]))
		par.connect("mouse_exited",close_discription)
		par.connect("pressed",hold_item.bind(inventory_slots[slot]))
		
	var main = get_parent()
	main.still = true
	var tween = create_tween()
	tween.tween_property(transition,"color:a",0.0,0.5)
	await tween.finished
	main.still = false

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

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			buttons_unfocus()

func buttons_unfocus():
	var pressed_button = button_group.get_pressed_button()

	if pressed_button:
		pressed_button.button_pressed = false

	get_viewport().gui_release_focus()

func add_item(item:Texture2D,item_name:String):
	var index = 0
	for slot in inventory:
		if slot == null:
			inventory[index] = item
			inventory_slots[index].texture = item
			inventory_slots[index].texture.resource_name = item_name
			return
		index += 1

func flash():
	transition.color = Color(1,1,1,1)
	var tween = create_tween()
	tween.tween_property(transition,"color:a",0,1)
	await tween.finished
	transition.color = Color(0,0,0,0)

func enter_elevator():
	var main = get_parent()
	main.still = true
	var tween = create_tween()
	tween.tween_property(transition,"color:a",1,1)
	await tween.finished
	get_tree().change_scene_to_file("res://Scenes/Elevator.tscn")

func remove_item(item:Texture2D):
	var index = 0
	for slot in inventory:
		if slot == item:
			inventory[index] = null
			inventory_slots[index].texture = null
			held_item = null
			buttons_unfocus()
			return true
		index += 1

func open_discription(slot:TextureRect):
	if slot.texture != null:
		description.position = slot.global_position + Vector2(-100,50)
		description.text = slot.texture.resource_name
		var tween = create_tween()
		tween.tween_property(description,"modulate:a",0.9, 0.2)
	elif description.modulate.a == 1:
		close_discription()

func close_discription():
	var tween = create_tween()
	tween.tween_property(description,"modulate:a",0, 0.2)

func hold_item(slot:TextureRect):
	if held_item == null:
		held_item = slot.texture
		get_viewport().gui_release_focus()
	else:
		held_item = null

func _on_menu_pressed():
	open_menu.emit()
