extends Button

@onready var texture = $TextureRect
@onready var audio = $AudioStreamPlayer2D

@export var white:AtlasTexture
@export var black:AtlasTexture

var color:int = 0
var Id:Vector2

func play_audio():
	audio.pitch_scale = randf_range(0.8,1.2)
	audio.play()

func init(id):
	Id = id

func _ready():
	texture.rotation = randf_range(0,360)

func pressed():
	texture.texture = white
	var tween = create_tween()
	tween.tween_property(texture,"modulate:a",1, 0.5)
	tween.parallel().tween_property(texture,"position:y",0.0,0.5)
	color = 1
	disabled = true
	await tween.finished
	play_audio()

func cappture():
	texture.texture = black
	var tween = create_tween()
	tween.tween_property(texture,"modulate:a",1, 0.5)
	tween.parallel().tween_property(texture,"position:y",0.0,0.5)
	color = 2
	disabled = true
	await tween.finished
	play_audio()

func release():
	var tween = create_tween()
	tween.tween_property(texture,"modulate:a",0, 0.5)
	tween.parallel().tween_property(texture,"position:y",-22.0,0.5)
	color = 0
	disabled = false
	await tween.finished
