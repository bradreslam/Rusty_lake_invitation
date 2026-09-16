extends Node2D

@onready var animation = $AnimationPlayer
@onready var seeds_texture = $Cage_bowl/Seeds
@onready var egg = $Cage_bowl/Egg
@onready var seed_bowl_button = $Cage_bowl/Button
@onready var harvey = $Harvey
@onready var harvey_button = $Harvey/Harvey_button
@onready var audio = $AudioStreamPlayer2D

var moving = false
var egg_exposed = false
var seeds_in_bowl = false

signal seeds_planted
var seeds_alt_1 = load("res://Assets/Sprites/bird_seeds_pile_half.png")

var sounds = [load("res://Assets/Audio/parrot_scream.wav"),load("res://Assets/Audio/wing.wav"),load("res://Assets/Audio/termite_bite.wav")]

func play_audio(sound:int):
	audio.stream = sounds[sound]
	audio.play()

func _on_button_pressed():
	var UI = get_parent().find_child("UI")
	if egg_exposed:
		var tween = create_tween()
		tween.tween_property(egg,"position:y",-140,1.5)
		tween.tween_property(egg,"modulate:a",0,0.5)
		await tween.finished
		UI.add_item(egg.texture,"Black egg")
		seed_bowl_button.disabled = true
		return
	
	var seeds = load("res://Assets/Sprites/bird_seeds_pile.png")
	if UI.held_item == seeds:
		var tween = create_tween()
		seeds_planted.emit()
		UI.remove_item(seeds)
		tween.parallel().tween_property(seeds_texture,"position:y",-66,0.5)
		tween.parallel().tween_property(seeds_texture,"modulate:a",1,0.5)
		await tween.finished
		seeds_in_bowl = true
		egg.visible = true

func _on_harvey_button_pressed():
	if !moving:
		moving = true
		if egg_exposed:
			animation.play("harvey_flap")
		else:
			animation.play("Harvey_eat")

func change_seeds():
	if seeds_texture.texture != seeds_alt_1:
		seeds_texture.texture = seeds_alt_1
	else:
		seeds_texture.visible = false
		egg_exposed = true

func enable_harvey():
	harvey.visible = true
	harvey_button.disabled = false


func _on_animation_player_animation_finished(_anim_name):
	moving = false
