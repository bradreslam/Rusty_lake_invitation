extends Node2D

@onready var audio = $AudioStreamPlayer2D

var repeating = false
var fading = false

func start_gears():
	audio.stream = load("res://Assets/Audio/gear_click.wav")
	repeating = true
	audio.play()

func start_fade():
	fading = true

func _on_audio_stream_player_2d_finished():
	if repeating:
		if fading:
			audio.volume_db -= 10
			if audio.volume_db < -60:
				repeating = false
		audio.play()
