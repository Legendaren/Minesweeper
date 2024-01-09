class_name CellUtils
extends Node

static var rng = RandomNumberGenerator.new()

static func in_bounds(grid: Array[Array], row: int, col: int) -> bool:
	var row_count: int = len(grid)
	var column_count: int = len(grid[0])
	var row_in_bounds = row >= 0 and row < row_count
	var col_in_bounds = col >= 0 and col < column_count
	return row_in_bounds and col_in_bounds

static func random_pos(grid: Array[Array]) -> Vector2i:
	var row_count = len(grid)
	var column_count = len(grid[0])
	var random_row = rng.randi_range(0, row_count - 1)
	var random_col = rng.randi_range(0, column_count - 1)
	return Vector2i(random_row, random_col)
