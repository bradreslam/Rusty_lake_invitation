extends Node2D

@onready var grid = $Sprite2D/GridContainer
@onready var button_sprite = $Button/Sprite2D
@onready var seeds_button = $Button
@onready var timer = $Timer
@onready var audio_player = $AudioStreamPlayer2D

var button = preload("res://Assets/Components/Go_button.tscn")

var buttons = {}

var lines = []

var player_turn = true

var winning_line = null

var pick_up_seeds
var win_game

func play_audio(sound):
	audio_player.stream = sound
	audio_player.play()

func _ready():
	var x = 1
	var y = 1
	for collum in grid.columns:
		for row in grid.columns:
			var ins_but = button.instantiate()
			ins_but.init(Vector2(x,y))
			ins_but.connect("pressed",Place_stone.bind(ins_but.Id))
			grid.add_child(ins_but)
			buttons.get_or_add(Vector2(x,y), ins_but)
			x += 1
		x = 1
		y += 1

func Place_stone(id:Vector2):
	if player_turn:
		player_turn = false
		var but = buttons[id]
		but.pressed()
		check_line(id)
		timer.wait_time = randf_range(0.5, 1.5)
		timer.start()

func sort_decending(a,b):
	if a.priority > b.priority:
		return true
	return false

func return_priority(a):
	return a.priority

func Respond(): #Picks a line based on priority
	lines.sort_custom(sort_decending)
	var prioritys = lines.map(return_priority)
	if prioritys[0] > 5:
		var count = 0
		while prioritys[count] == prioritys[0]:
			if count == prioritys.size()-1:
				break
			count += 1
		Place_at_line(lines[randi_range(0,count-1)])
	else:
		if lines[0].priority == 1:
			if randi_range(0,1) == 1:
				place_stone_at_random()
				return
		var duplicated_lines = []
		for line in lines:
			for n in line.priority:
				duplicated_lines.append(line)
		if duplicated_lines.size() == 0:
			place_stone_at_random()
			return
		Place_at_line(duplicated_lines[randi_range(0,duplicated_lines.size()-1)])

func place_stone_at_random():
	while true:
		var y = randi_range(3,17)
		var x = randi_range(3,17)
		if buttons[Vector2(x,y)].color == 0:
			buttons[Vector2(x,y)].cappture()
			check_line(Vector2(x,y))
			player_turn = true
			break

func Place_at_line(Line): #places a stone at a position based on a line
	var placed_button
	if Line.colors.size() == 1:
		while true:
			var stone = Line.colors[0].Id
			if stone.y > 2 && stone.y < 18 && stone.x > 2 && stone.x < 18:
				var new_dir = Vector2(randi_range(-1,1),randi_range(-1,1))
				if new_dir != Vector2.ZERO:
					buttons[stone + new_dir].cappture()
					check_line(stone + new_dir)
					player_turn = true
					return
			place_stone_at_random()
			return
	if Line.openings == 0:
		if randi() % 2:
			placed_button = buttons[Line.colors[0].Id + Line.direction * Vector2(-1,-1)]
		else:
			placed_button = buttons[Line.colors.back().Id + Line.direction]
	elif Line.openings == 1:
		placed_button = buttons[Line.colors[0].Id + Line.direction * Vector2(-1,-1)]
	else:
		placed_button = buttons[Line.colors.back().Id + Line.direction]
	
	placed_button.cappture()
	
	check_line(placed_button.Id)
	
	player_turn = true

func compare_arrays(Array_to_check, Array_to_match):#Check if array_to_check contains array_to_match and returns the index of the first occurance if the array to match in array to check return null otherwise.
	var i = 0
	if Array_to_check.size() < Array_to_match.size():
		return null
	while i <= Array_to_check.size() - (Array_to_match.size()):
		if Array_to_check[i].color == Array_to_match[0]:
			var index = i
			for col in Array_to_match:
				if i == Array_to_check.size():
					break
				if col == Array_to_check[i].color:
					i += 1
					if i - index == Array_to_match.size():
						return index
				else:
					break
		else:
			i += 1
	return null

func check_for_broken_winning_lines(new_line,line):
	var front_id = new_line.colors[0].Id + (new_line.direction * Vector2(-1,-1)) *2
	var back_id = new_line.colors.back().Id + new_line.direction * 2
	if !check_if_id_on_board(front_id) || !check_if_id_on_board(back_id):
		return
	var front_stone = buttons[front_id]
	var back_stone = buttons[back_id]
	if back_stone == line.colors[0]:
		var count1 = count_line_end(new_line.colors, false, new_line.colors.back().color)
		var count2 = count_line_end(line.colors, true, new_line.colors.back().color)
		
		if count1 + count2 > 3:
			line.priority = 9
			line.openings = 1
			return
	elif front_stone == line.colors.back():
		var count1 = count_line_end(new_line.colors, true, new_line.colors[0].color)
		var count2 = count_line_end(line.colors, false, new_line.colors[0].color)

		if count1 + count2 > 3:
			line.priority = 9
			line.openings = 2
			return
	elif front_stone == line.colors[0]:
		var count1 = count_line_end(new_line.colors, true, new_line.colors[0].color)
		var count2 = count_line_end(line.colors, true, new_line.colors[0].color)

		if count1 + count2 > 3:
			line.priority = 9
			line.openings = 1
			return
		
	elif back_stone == line.colors.back():
		var count1 = count_line_end(new_line.colors, false, new_line.colors.back().color)
		var count2 = count_line_end(line.colors, false, new_line.colors.back().color)
		
		if count1 + count2 > 3:
			line.priority = 9
			line.openings = 2
			return

func count_line_end(colors:Array, from_front:bool, color_to_match:int):
	var list = colors.duplicate()
	if !from_front:
		list.reverse()
	
	var count = 0
	while count + 1 <= list.size() and list[count].color == color_to_match:
		count += 1

	return count

func check_if_id_on_board(id:Vector2):
	if id.x > 0 && id.x < 20 && id.y > 0 && id.y < 20:
		return true
	return false

func check_line(id:Vector2): #Checks if a line is created or changed
	var directions_to_check = [Vector2(0,1),Vector2(-1,1),Vector2(-1,0),Vector2(-1,-1)
	,Vector2(0,-1),Vector2(1,-1),Vector2(1,0),Vector2(1,1)]
	var new_lines = []
	var lines_to_remove = []
	var lines_to_add = []
	for dir in directions_to_check:
		if buttons.get(id+dir, button.instantiate()).color != 0:
			var line = Line_data.new()
			if buttons[id].color != 0:
				line.colors.append(buttons[id])
				for l in new_lines:
					if l.direction + dir == Vector2.ZERO:
						new_lines.erase(l)
						line = l
						line.colors.reverse()
						break
			line.direction = dir
			var i = 1
			while check_if_id_on_board(id+dir*i) && buttons[id+dir*i].color != 0:
				line.colors.append(buttons[id+dir*i])
				i += 1
			new_lines.append(line)
	
	
	if new_lines.size() == 0: # if the placed stone is on its own set custom values
		var line = Line_data.new()
		line.colors.append(buttons[id])
		line.set_formation()
		lines.append(line)
		return
	
	for l in new_lines: #check if new lines intersect with existing lines
		for line in lines:
			if line.direction == l.direction || line.direction == l.direction * Vector2(-1,-1) || line.direction == Vector2(0,0):
				if line.colors.has(l.colors[0]) || line.colors.has(l.colors.back()):
					lines_to_remove.append(line)
				else:
					check_for_broken_winning_lines(l,line)
		for line in lines_to_remove:
			lines.erase(line)
		lines_to_remove.clear()
	
	for l in new_lines:#checks if the game is won, or if stones are captured
		if !lines_to_remove.has(l):
			if l.colors.size() > 3:
				var hit = compare_arrays(l.colors,[1,2,2,1])
				if hit == null:
					hit = compare_arrays(l.colors,[2,1,1,2])
				if hit != null:
					lines_to_remove.append(l)
					l.colors[hit+1].release()
					l.colors[hit+2].release()
					var lines_to_check = []
					
					for line in lines:
						if line.colors.any(func(col): return col.color == 0):
							lines_to_check.append(line)
					
					for line in lines_to_check:
						lines.erase(line)
					
					for line in new_lines:
						if line != l:
							if line.colors.any(func(col): return col.color == 0):
								lines_to_check.append(line)
								lines_to_remove.append(line)
					
					for line in lines_to_check: # checks if an already existing line contains one of the hit stones
						var new_line = Line_data.new()
						while line.colors[0].color != 0:
							new_line.colors.append(line.colors[0])
							line.colors.pop_front()
						line.colors.pop_front()
						if new_line.colors.size() == 1:
							if !check_surounding_cells(new_line.colors[0].Id):
								lines_to_add.append(new_line)
						elif new_line.colors.size() != 0:
							new_line.direction = line.direction
							lines_to_add.append(new_line)
						if line.colors.size() == 1:
							if !check_surounding_cells(line.colors[0].Id):
								lines_to_add.append(line)
						elif line.colors.size() != 0:
							lines_to_add.append(line)
					
					
					var new_line_1 = Line_data.new()
					if hit == 0:
						if check_surounding_cells(l.colors[0].Id):
							new_line_1.colors.append(l.colors[0])
					else:
						var i = 0
						new_line_1.direction = l.direction
						while i <= hit:
							new_line_1.colors.append(l.colors[i])
							i += 1
					var new_line_2 = Line_data.new()
					if hit == l.colors.size()-4:
						if check_surounding_cells(l.colors.back().Id):
							new_line_2.colors.append(l.colors.back())
					else:
						var i = hit+3
						new_line_2.direction = l.direction
						while i < l.colors.size():
							new_line_2.colors.append(l.colors[i])
							i += 1
					if new_line_1.colors.size() != 0:
						lines_to_add.append(new_line_1)
					if new_line_2.colors.size() != 0:
						lines_to_add.append(new_line_2)
					
				elif l.colors.size() > 4:
					if compare_arrays(l.colors,[1,1,1,1,1]) != null:
						game_won()
						return
					elif compare_arrays(l.colors,[2,2,2,2,2]) != null:
						winning_line = l
						reset_game()
						return
	
	for line in lines_to_remove:
		new_lines.erase(line)
	
	for line in lines_to_add:
		new_lines.append(line)
	
	for line in new_lines:
		line.set_formation()
	
	lines.append_array(new_lines)

func check_if_lines_contain_button(lines_to_check,butt):
	for line in lines_to_check:
		if line.colors.has(butt):
			return true
	return false

func check_surounding_cells(id):
	var directions = [Vector2(1,1),Vector2(1,0),Vector2(1,-1),Vector2(0,1),
	Vector2(0,-1),Vector2(-1,1),Vector2(-1,0),Vector2(-1,-1)]
	for dir in directions:
		if check_if_id_on_board(id+dir):
			if buttons[id+dir].color != 0:
				return true
	return false

func reset_game():
	player_turn = false
	lines = []
	for butt in buttons:
		var button_inst = buttons[butt]
		if button_inst.modulate.a != 0 && !winning_line.colors.has(button_inst):
			button_inst.release()
	timer.wait_time = 1
	timer.start()

func game_won():
	get_parent().find_child("Room2").view_shade()
	timer.queue_free()
	var tween = create_tween()
	play_audio(win_game)
	for butt in buttons:
		var button_inst = buttons[butt]
		button_inst.disabled = true
		if button_inst.modulate.a != 0:
			tween.parallel().tween_property(button_inst,"global_position",seeds_button.global_position,0.7)
	tween.parallel().tween_property(button_sprite,"modulate:a",1,0.5)
	seeds_button.mouse_filter = Control.MOUSE_FILTER_STOP
	await tween.finished
	grid.queue_free()
	seeds_button.disabled = false

func _on_button_pressed():
	seeds_button.disabled = true
	var UI = get_parent().find_child("UI")
	UI.add_item(load("res://Assets/Sprites/bird_seeds_pile.png"),"Bird seeds")
	play_audio(pick_up_seeds)
	var tween = create_tween()
	tween.tween_property(button_sprite,"modulate:a",0,0.5)
	await tween.finished
	seeds_button.queue_free()

func _on_timer_timeout():
	if winning_line != null:
		for col in winning_line.colors:
			col.release()
		winning_line = null
		player_turn = true
	else:
		Respond()
