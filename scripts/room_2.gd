extends Node2D

@onready var cage = $Bird_cage

var seeds_in_cage = false

signal Open(position:Vector2)

func _on_bird_cage_button_pressed():
	Open.emit(Vector2(1660.0,-1265.0))


func _on_puzzle_2_button_pressed():
	Open.emit(Vector2(1662.0,1170.0))

func enable_parrot():
	var cage_with_harvey = load("res://Assets/Sprites/birdcage_with_harvey.png")
	cage.texture = cage_with_harvey
