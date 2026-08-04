extends Node

class_name Line_data

var prioritys = {
	[2]: 2,
	[1,2]: 1,
	[2,2]: 4,
	[2,2,1]: 7,
	[2,2,2]: 8,
	[2,2,2,1]: 5,
	[2,2,2,2]: 10,
	[2,2,2,2,1]: 10,
	[1]: 3,
	[2,1]: 1,
	[1,1]: 4,
	[1,1,2]: 6,
	[1,1,1]: 9,
	[1,1,1,2]: 4,
	[1,1,1,1]: 1,
	[1,1,1,1,2]: 9,
}

var colors = [] #1 = white 2 = black
var priority
var openings # 0 means stones can be placed on both sides, 1 means only at the start, 2 means only at the end
var direction = Vector2(0,0)

func set_formation(): #Sets the priority and openings based on the amount of one color in a row
	if colors.size() == 1:
		if colors[0].color == 1:
			priority = 1
		else:
			priority = 2
		direction = Vector2(1,1)
		return
	var border_start = check_border(direction * Vector2(-1,-1), colors.front().Id)
	var border_end = check_border(direction, colors.back().Id)
	if border_start && border_end:
		priority = 0
	else:
		var back_priority = 0
		var front_priority = 0
		var back_barred = false
		var front_barred = false
		if !border_start:
			var col_1 = colors.front()
			var front_count = 0
			for col in colors:
				if col.color == col_1.color:
					front_count += 1
				else:
					front_barred = true
					break
			front_priority = get_priority(front_count, col_1.color, front_barred)
		if !border_end:
			var col_2 = colors.back()
			var back_count = 0
			var rev_colors = colors.duplicate()
			rev_colors.reverse()
			for col in rev_colors:
				if col.color == col_2.color:
					back_count += 1
				else:
					back_barred = true
					break
			back_priority = get_priority(back_count, col_2.color, back_barred)
		
		if back_priority > front_priority:
			priority = back_priority
			if back_barred == true || border_start:
				openings = 2
				return
		else:
			priority = front_priority
			if front_barred == true || border_end:
				openings = 1
				return
		openings = 0

func check_border(dir:Vector2, index:Vector2):
	var checked_cell = index + dir
	if checked_cell.x ==  0 || checked_cell.x == 20 || checked_cell.y == 0 || checked_cell.y == 20:
		return true
	else:
		return false

func get_priority(count:int, color:int, barred:bool):
	var line = []
	for col in count:
		line.append(color)
	if barred:
		if color == 1:
			line.append(2)
		else:
			line.append(1)
	return prioritys[line]
