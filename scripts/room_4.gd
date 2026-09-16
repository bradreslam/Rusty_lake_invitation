extends Node2D

@onready var odd_tree_1 = $Odd_tree_1
@onready var odd_tree_2 = $Odd_tree_2
@onready var tree = $Tree
@onready var blood = $Blood_droplet
@onready var blood_button = $Blood_droplet/Button
@onready var tree_crack_1 = $Odd_tree_1/Sprite2D
@onready var tree_crack_2 = $Odd_tree_2/Sprite2D
@onready var audio = $AudioStreamPlayer2D

var tree_1_down = load("res://Assets/Sprites/odd_tree_1_down.png")
var tree_2_down = load("res://Assets/Sprites/odd_tree_2_down.png")

var puzzle_1_1_solved = false
var puzzle_1_2_solved = false

var tree_state = 0

signal Open(position:Vector2)

func on_tree_2_down():
	odd_tree_2.position = Vector2(-544,133)
	odd_tree_2.texture = tree_2_down
	tree_crack_2.visible = false
	if tree_state == 0:
		
		tree.play("Grow1")
		tree_state = 1
	elif tree_state == 1:
		audio.play()
		tree.play("Grow2")
		tree_state = 2

func on_tree_1_down():
	odd_tree_1.position = Vector2(182,152)
	odd_tree_1.texture = tree_1_down
	tree_crack_1.visible = false
	if tree_state == 0:
		audio.play()
		tree.play("Grow1")
		tree_state = 1
	elif tree_state == 1:
		audio.play()
		tree.play("Grow2")
		tree_state = 2


func _on_tree_1_button_pressed():
	Open.emit(Vector2(-1500.0,-1278.0))

func _on_tree_2_button_pressed():
	Open.emit(Vector2(-1500.0,1184.0))


func _on_visible_on_screen_notifier_2d_screen_entered():
	if puzzle_1_1_solved:
		puzzle_1_1_solved = false
		on_tree_1_down()
	elif puzzle_1_2_solved:
		puzzle_1_2_solved = false
		on_tree_2_down()


func _on_puzzle_1_1_puzzle_1_1_finished():
	puzzle_1_1_solved = true


func _on_puzzle_1_2_puzzle_1_2_finished():
	puzzle_1_2_solved = true


func _on_button_pressed():
	blood.visible = false
	blood_button.disabled = true
	var UI = get_parent().find_child("UI")
	UI.add_item(load("res://Assets/Sprites/blood_drop.png"),"Blood drop")


func _on_blood_droplet_animation_finished():
	blood_button.disabled = false


func _on_tree_animation_finished():
	if tree_state == 2:
		blood.visible = true
		blood.play("drip")
