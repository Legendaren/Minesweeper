class_name CellUtils
extends Node

static var rng = RandomNumberGenerator.new()

static func in_bounds(grid: Array[Array], row: int, col: int) -> bool:
	var row_count: int = len(grid)
	var column_count: int = len(grid[0])
	var row_in_bounds := row >= 0 and row < row_count
	var col_in_bounds := col >= 0 and col < column_count
	return row_in_bounds and col_in_bounds


static func random_pos(grid: Array[Array]) -> Vector2i:
	var row_count: int = len(grid)
	var column_count: int = len(grid[0])
	var random_row: int = rng.randi_range(0, row_count - 1)
	var random_col: int = rng.randi_range(0, column_count - 1)
	return Vector2i(random_row, random_col)


static func neighbor_positions(grid: Array[Array], row: int, col: int) -> Array:
	var top_left = [row-1, col-1]
	var top_center = [row-1, col]
	var top_right = [row-1, col+1]
	var center_left = [row, col-1]
	var center_right = [row, col+1]
	var bottom_left = [row+1, col-1]
	var bottom_center = [row+1, col]
	var bottom_right = [row+1, col+1]
	var possible_positions = [top_left, top_center, top_right, center_left, center_right, bottom_left, bottom_center, bottom_right]
	var valid_positions = []
	for pos in possible_positions:
		var r = pos[0]
		var c = pos[1]
		if CellUtils.in_bounds(grid, r, c):
			valid_positions.append(pos)
	return valid_positions
