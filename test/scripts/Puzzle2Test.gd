# GdUnit generated TestSuite
class_name Puzzle2Test
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source: String = 'res://scripts/puzzle_2.gd'

var button = preload("res://Assets/Components/Go_button.tscn")
var puzzle2 = preload("res://Scenes/puzzle_2.tscn")

func before() -> void:
	puzzle2 = auto_free(puzzle2.instantiate())
	puzzle2._ready()

func test_check_if_new_lines_extend_excisting_lines() -> void:
	
	assert_not_yet_implemented()


func test_check_if_line_1_long() -> void:
	var line_1 = auto_free(Line_data.new())
	line_1.colors.append(button.instantiate())
	var line_2 = auto_free(Line_data.new())
	line_2.colors.append(button.instantiate())
	line_2.colors.append(button.instantiate())
	
	assert_bool(puzzle2.check_if_line_1_long([line_1,line_2],Vector2(1,1))).is_false()
	assert_bool(puzzle2.check_if_line_1_long([],Vector2(1,1))).is_true()


func test_check_if_id_on_board() -> void:
	
	assert_bool(puzzle2.check_if_id_on_board(Vector2(-1,10))).is_false()
	assert_bool(puzzle2.check_if_id_on_board(Vector2(29,1))).is_false()
	assert_bool(puzzle2.check_if_id_on_board(Vector2(1,19))).is_true()


func test_count_line_end() -> void:
	# remove this line and complete your test
	assert_not_yet_implemented()


func test_check_for_broken_winning_lines() -> void:
	# remove this line and complete your test
	assert_not_yet_implemented()


func test_compare_arrays() -> void:
	# remove this line and complete your test
	assert_not_yet_implemented()


func test_check_if_lines_contain_button() -> void:
	# remove this line and complete your test
	assert_not_yet_implemented()


func test_check_surounding_cells() -> void:
	# remove this line and complete your test
	assert_not_yet_implemented()
