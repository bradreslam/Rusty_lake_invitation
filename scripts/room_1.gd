extends Node2D

@onready var bell = $Statue/Sprite2D2/Sprite2D/AnimatedSprite2D
@onready var bell_button = $Statue/Sprite2D2/Sprite2D/AnimatedSprite2D/Button
@onready var statue = $Statue/Sprite2D2/Sprite2D
@onready var animation = $AnimationPlayer
@onready var right_wave = $Statue/Right_outline
@onready var left_wave = $Statue/Left_outline
@onready var right_wave_ray = $Statue/Right_outline/RayCast2D
@onready var left_wave_ray = $Statue/Left_outline/RayCast2D
@onready var blood = $Blood_drop
@onready var egg = $Egg_drop
@onready var line = $Statue/Line2D
@onready var timer = $Timer
@onready var drop_button = $DropButton
@onready var transition = $Transition
@onready var audio = $AudioStreamPlayer2D

var statue_position
var moving = false
var statue_state = 0

func _on_button_pressed():
	bell.play("Ring")
	timer.start()

func move_statue():
	moving = true
	statue_position = statue.position.x
	if statue_state == 0:
		statue_state = 1
		animation.play("Rising_1")
	elif statue_state == 1:
		animation.play("Rising_2")

func _physics_process(_delta):
	if moving:
		statue.offset.x = randf_range(-3.0,3.0)
		bell.offset.x = randf_range(-3.0,3.0)
		right_wave.position.x = right_wave_ray.get_collision_point().x - 7
		left_wave.position.x = left_wave_ray.get_collision_point().x + 8
		line.set_point_position(0, right_wave.global_position - line.global_position)
		line.set_point_position(1, left_wave.global_position - line.global_position)

func _on_animation_player_animation_finished(anim_name):
	moving = false
	statue.offset.x = 0
	bell.offset.x = 0
	if anim_name == "Rising_2":
		bell_button.disabled = false
		drop_button.queue_free()
	elif anim_name == "Blood_drop":
		move_statue()
	elif anim_name == "Rising_1":
		drop_button.disabled = false

func _on_drop_button_pressed():
	var blood_drop = load("res://Assets/Sprites/blood_drop.png")
	var egg_drop = load("res://Assets/Sprites/black_egg.png")
	var UI = get_parent().find_child("UI")
	if UI.held_item == blood_drop:
		if UI.remove_item(blood_drop):
			drop_button.disabled = true
			blood.visible = true
			animation.play("Blood_drop")
	elif UI.held_item == egg_drop:
		if UI.remove_item(egg_drop):
			drop_button.disabled = true
			egg.visible = true
			animation.play("Egg_drop")

func _on_timer_timeout():
	moving = true
	animation.play("Elevator_rise")

func moving_false():
	moving = false

func _on_enter_elevator_pressed():
	var main = get_parent()
	main.still = true
	var tween = create_tween()
	tween.tween_property(transition,"color:a",1,1)
	await tween.finished
	get_tree().change_scene_to_file("res://Scenes/Elevator.tscn")

func _on_water_splash_animation_finished():
	move_statue()
