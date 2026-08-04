extends Node2D

@onready var sprite = $Sprite2D
@onready var particle = $cell_particle

var id:int
var pointed = false
var pointer_color = null

@onready var cell_sprites = [ load("res://Assets/Sprites/puzzle_1_cell_1.png"),
load("res://Assets/Sprites/puzzle_1_cell_2.png"),
load("res://Assets/Sprites/puzzle_1_cell_3.png")]

signal start_line(id:int)
signal mouse_enter(id:int)

func set_pointer(Pointed, color):
	pointed = Pointed
	pointer_color = color
	queue_redraw()

func _on_puzzle_puzzle_finished():
	particle.emitting = true
	sprite.visible = false
	pointed = false
	queue_redraw()

func _ready():
	get_parent().connect("puzzle_finished", _on_puzzle_puzzle_finished)
	var texture = cell_sprites.pick_random()
	sprite.texture = texture
	particle.texture = texture

func _draw():
	if pointed:
		draw_circle(Vector2.ZERO,20.0, pointer_color, true)

func _on_area_2d_mouse_entered():
	mouse_enter.emit(id)

func _on_area_2d_input_event(_viewport, _event, _shape_idx):
	if Input.is_action_just_pressed('click'):
		start_line.emit(id)
