extends Node

@export var puzzle_name:String
@export var rows:int
@export var collums:int
@export var pointed_cells:Dictionary[int,Color]

@onready var border = $NinePatchRect

var grid_cell:PackedScene = preload("res://Assets/Components/Connect_the_dots_cell.tscn")
var termite:PackedScene = preload("res://Assets/Components/termite.tscn")

var dragging = false

var cells = []

var termites = []

var termites_finished = 0

var lines = []

var current_cell

var current_line : Line2D

signal puzzle_finished

func _ready():
	var termite_colors = []
	for r in rows:
		for c in collums:
			var cell:Node2D = grid_cell.instantiate()
			cell.position = Vector2(r*100,c*100)
			cell.connect("start_line",_start_line)
			cell.connect("mouse_enter",_new_cell)
			cells.append(cell)
			cell.id = cells.size()-1
			if pointed_cells.has(cell.id):
				var color = pointed_cells[cell.id]
				cell.set_pointer(true, color)
				if !termite_colors.has(color.to_abgr32()):
					termite_colors.append(color.to_abgr32())
					var term = termite.instantiate()
					term.init(color)
					term.position = cell.position
					add_child(term)
					term.connect("termite_finished",termite_finished)
					termites.append(term)
			add_child(cell)
	border.size = Vector2((rows * 100)+25, (collums * 100)+23)

func _start_line(id):
	var intersecting_line = check_lines(id)
	if intersecting_line != null:
		current_line = intersecting_line
		dragging = true
		add_line_point(id)
	elif cells[id].pointed:
		dragging = true
		current_cell = id
		current_line = Line2D.new()
		current_line.z_index = -1
		current_line.width = 15
		current_line.joint_mode = Line2D.LINE_JOINT_ROUND
		current_line.default_color = cells[id].pointer_color
		current_line.add_point(cells[id].position)
		lines.append(current_line)
		add_child(current_line)

func _input(event):
	if dragging && event.is_action_released("click"):
		if current_line.points.size() > 1 && cells[current_cell].pointed:
			dragging = false
			end_game()
		else:
			dragging = false
			lines.erase(current_line)
			current_line.queue_free()
			current_line = null

func end_game():
	var line_points = 0
	for line in lines:
		line_points += line.points.size()
	if line_points == cells.size():
		set_process_input(false)
		for cell in cells:
			cell.disconnect("start_line",_start_line)
		for term in termites:
			for line in lines:
				var points = line.points
				if points[0] == term.position:
					var difference = term.position
					var adjusted_points = []
					for point in points:
						point -= difference
						adjusted_points.append(point)
					term.follow_line(adjusted_points)
				elif points[points.size()-1] == term.position:
					var difference = term.position
					var adjusted_points = []
					for point in points:
						point -= difference
						adjusted_points.append(point)
					adjusted_points.reverse()
					term.follow_line(adjusted_points)

func termite_finished():
	termites_finished += 1
	if termites_finished == termites.size():
		puzzle_finished.emit()
		for line in lines:
			line.queue_free()
		for term in termites:
			term.fall()
		border.queue_free()

func check_lines(id):
	var pos = cells[id].position
	for line in lines:
		if line.points.has(pos):
			return line
	return null

func add_line_point(id):
	var new_pos = cells[id].position
	var intersect_line = check_lines(id)
	if intersect_line == null:
		if cells[current_cell].pointed && current_line.points.size() > 1:
			return
		current_line.add_point(new_pos)
		current_cell = id
	elif intersect_line == current_line:
		var index = current_line.points.find(new_pos)
		var count = current_line.points.size() - 1
		while count != index:
			current_line.remove_point(count)
			count -= 1
		current_cell = id

func _new_cell(id):
	if dragging:
		if !cells[id].pointed || cells[id].pointer_color.to_abgr32() == current_line.default_color.to_abgr32():
			if current_cell + collums == id || current_cell - collums == id:
				add_line_point(id)
			elif (current_cell / collums) % 1 == 0 && current_cell + 1 == id:
				add_line_point(id)
			elif ((current_cell - collums) / collums) % 1 == 0 && current_cell - 1 == id:
				add_line_point(id)
			elif current_cell -1 == id || current_cell +1 == id:
				add_line_point(id)
