extends Node2D

@onready var cage = $Bird_cage
@onready var audio = $Parrot_player
@onready var shade = $AnimatedSprite2D
@onready var timer = $Timer

var seeds_in_cage = false

signal Open(position:Vector2)

func _on_bird_cage_button_pressed():
	Open.emit(Vector2(1660.0,-1265.0))


func _on_puzzle_2_button_pressed():
	Open.emit(Vector2(1662.0,1170.0))

func view_shade():
	shade.visible = true

func enable_parrot():
	play_parrot_flight()
	var cage_with_harvey = load("res://Assets/Sprites/birdcage_with_harvey.png")
	cage.texture = cage_with_harvey

func play_parrot_flight():
	audio.volume_db = -15
	audio.stream = load("res://Assets/Audio/wing.wav")
	audio.play()

func _on_visible_on_screen_notifier_2d_screen_entered():
	if shade.visible == true:
		timer.start()


func _on_timer_timeout():
	var UI = get_parent().find_child("UI")
	UI.flash()
	audio.stream = load("res://Assets/Audio/flash.wav")
	audio.play()
	shade.queue_free()


func _on_parrot_player_finished():
	if audio.stream == load("res://Assets/Audio/wing.wav"):
		audio.pitch_scale = randf_range(0.8,1.2)
		audio.volume_db += 5
		if audio.volume_db < 10:
			audio.play()
