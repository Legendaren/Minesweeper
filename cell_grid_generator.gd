class_name CellGridGenerator
extends Node

var cell_scene = preload("res://Scenes/cell.tscn")

func generate_empty_grid(row_count: int, column_count: int) -> Array[Array]:
	var grid : Array[Array] = []
	for i in row_count:
		var row: Array[CellComponent] = []
		for j in column_count:
			var cell_instance: CellComponent = cell_scene.instantiate()
			cell_instance.init_cell()
			row.append(cell_instance)
		grid.append(row)
	return grid


func add_mine_to_grid(grid: Array[Array]):
	var row_count = len(grid)
	var column_count = len(grid[0])
	var random_pos = CellUtils.random_pos(grid)
	var random_row = random_pos.x
	var random_col = random_pos.y
	while grid[random_row][random_col].cell_state == Enums.CellState.MINE:
		random_pos = CellUtils.random_pos(grid)
		random_row = random_pos.x
		random_col = random_pos.y
	
	print(str(random_row) + " " + str(random_col))
	var cell_instance: CellComponent = cell_scene.instantiate()
	cell_instance.set_as_mine()
	grid[random_row][random_col] = cell_instance
	increment_neighbor_mines(grid, random_row, random_col)


func increment_neighbor_mines(grid: Array[Array], row: int, col: int) -> void:
	for pos in neighbor_positions(grid, row, col):
		var r = pos[0]
		var c = pos[1]
		if CellUtils.in_bounds(grid, r, c):
			grid[r][c].neighbor_mine_count += 1


func update_cells_based_on_neighbor_mines(grid: Array[Array]):
	for i in range(grid.size()):
		for j in range(grid[0].size()):
			var cell: CellComponent = grid[i][j]
			cell.init_cell()

func neighbor_positions(grid: Array[Array], row: int, col: int) -> Array:
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
