class_name CellUtils
extends Node

const cube_direction_vectors: Array[Vector3i] = [
	Vector3i(+1, 0, -1), Vector3i(+1, -1, 0), Vector3i(0, -1, +1),
	Vector3i(-1, 0, +1), Vector3i(-1, +1, 0), Vector3i(0, +1, -1),
]

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


static func cube_to_oddr(pos: Vector3i) -> Vector2i:
	var col: int = pos.x + (pos.y - (pos.y & 1)) / 2
	var row: int = pos.y
	return Vector2i(col, row)


static func oddr_to_cube(pos: Vector2i) -> Vector3i:
	var q: int = pos.x - (pos.y - (pos.y & 1)) / 2
	var r: int = pos.y
	return Vector3i(q, r, -q-r)


static func cube_distance(a: Vector3i, b: Vector3i) -> int:
	var vec: Vector3i = a - b
	return (abs(vec.x) + abs(vec.y) + abs(vec.z)) / 2


static func cube_neighbors(cube: Vector3i) -> Array[Vector3i]:
	var neighbors: Array[Vector3i] = []
	for vec in cube_direction_vectors:
		neighbors.append(vec + cube)
	return neighbors
