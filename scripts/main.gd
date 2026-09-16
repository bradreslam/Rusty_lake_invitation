extends Node2D

@onready var camera:Camera2D = $Camera2D
@onready var room1:Node2D = $Room1
@onready var room2:Node2D = $Room2
@onready var room3:Node2D = $Room3
@onready var room4:Node2D = $Room4
@onready var cage: = $BirdCage
@onready var UI:CanvasLayer = $UI
@onready var audio = $Ambient_sounds
@onready var timer = $Timer

var menu:PackedScene = preload("res://Scenes/settings.tscn")

var sounds = [load("res://Assets/Audio/wind1.wav"),load("res://Assets/Audio/wind2.wav"),load("res://Assets/Audio/Background_bird.wav")]

var current_room = 1
var moving = false
var rooms = {}
var still = false
var menu_open = false
var parrot_check = false

func _ready():
	rooms = {
		1:room1,
		2:room2,
		3:room3,
		4:room4
	}
	timer.wait_time = randi_range(5,10)
	timer.start()

func move(direction: bool):
	if !moving:
		moving = true
	
		if direction:
			if current_room == 4:
				move_room(true)
				current_room = 1
			else:
				current_room += 1
		else:
			if current_room == 1:
				move_room(true)
				current_room = 4
			else:
				current_room -= 1
		
		var tween = create_tween()
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(camera,"offset",rooms[current_room].position,0.5)
		await tween.finished
		if parrot_check:
			parrot_check = false
			room2.enable_parrot()
			cage.enable_harvey()
		move_room(false)
		
		moving = false

func move_room(direction: bool):
	if direction:
		if rooms[current_room] == room1:
			camera.offset = Vector2(4608.0,0.0)
			room1.position = Vector2(4608.0,0.0)
		else:
			room1.position = Vector2(4608.0,0.0)
	else:
		if rooms[current_room] == room1:
			camera.offset = Vector2(0.0,0.0)
			room1.position = Vector2(0.0,0.0)
		else:
			room1.position = Vector2(0.0,0.0)

func _on_left_input_event(_viewport, _event, _shape_idx):
	move(false)

func _on_right_input_event(_viewport, _event, _shape_idx):
	move(true)

func _input(event):
	if event.is_action_pressed("left"):
		if !still:
			move(false)
	elif event.is_action_pressed("right"):
		if !still:
			move(true)
	elif event.is_action_pressed("back"):
		if still:
			camera.offset = rooms[current_room].position
			UI.Close()
			still = false
	elif event.is_action_pressed("Settings") && !menu_open:
		menu_open = true
		open_menu()
	elif event.is_action_released("Settings") && menu_open:
		if get_tree().paused == false:
			menu_open = false

func _on_ui_move(direction):
	if direction == 1:
		move(true)
	elif direction == 3:
		move(false)
	elif direction == 2:
		still = false
		camera.offset = rooms[current_room].position
		UI.Close()

func _on_room_4_open(Position):
	camera.offset = Position
	UI.Open()
	still = true

func open_menu():
	var menu_instance = menu.instantiate()
	add_child(menu_instance)
	get_tree().paused = true

func _on_ui_open_menu():
	open_menu()

func _on_room_2_open(Position):
	camera.offset = Position
	UI.Open()
	still = true

func _on_bird_cage_seeds_planted():
	parrot_check = true

func _on_timer_timeout():
	audio.stream = sounds.pick_random()
	audio.pitch_scale = randf_range(0.8,1.2)
	audio.play()
	timer.wait_time = randi_range(5,10)
	timer.start()
