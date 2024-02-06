extends Node
class_name HexGridGenerator

const NO_SELECTED_CUBE := Vector3i(0, 0, -1)

## The amount of empty neighboring adjacent cells for starting cell (first click)
@export_range(2, 10) var distance_limit: int = 2

## Generate a hex grid in a Dictionary
## Key = cube coordinate
## Value = object of type CellComponent

func generate_grid(start: Vector3i, radius_limit: int, mines: int) -> Dictionary:
	var empty_grid: Dictionary = generate_empty_grid(start, radius_limit)
	var grid_with_mines: Dictionary = add_mines_to_grid(empty_grid, mines)
	_update_mine_count(grid_with_mines)
	return grid_with_mines


func generate_empty_grid(start: Vector3i, radius_limit: int) -> Dictionary:
	var grid = {}
	var stack = []
	stack.append(start)
	while not stack.is_empty():
		var cube = stack.pop_back()
		grid[cube] = CellComponent.new(cube)
		var neighbors: Array[Vector3i] = CellUtils.cube_neighbors(cube)
		for n in neighbors:
			if n not in grid and CellUtils.cube_distance(start, n) < radius_limit:
				stack.append(n)
	return grid


func add_mines_to_grid(grid: Dictionary, mines: int, first_cell: Vector3i = NO_SELECTED_CUBE) -> Dictionary:
	var added_mines := {}
	var new_grid := grid.duplicate(true)
	for i in range(mines):
		var random_cube: Vector3i = _random_cube_with_no_mine(grid, added_mines, first_cell)
		var random_cell: CellComponent = new_grid[random_cube]
		random_cell.state = Enums.CellState.MINE
		added_mines[random_cube] = true
	_update_mine_count(new_grid)
	return new_grid


func _update_mine_count(grid: Dictionary) -> void:
	for cell: CellComponent in grid.values():
		if cell.is_mine():
			continue
		cell.neighbor_mine_count = _calculate_neighbor_mine_count(grid, cell)
		if cell.neighbor_mine_count > 0:
			cell.state = Enums.CellState.NUMBER


func _calculate_neighbor_mine_count(grid: Dictionary, cell: CellComponent) -> int:
	var count := 0
	for cube: Vector3i in CellUtils.cube_neighbors(cell.pos):
		if cube in grid and grid[cube].state == Enums.CellState.MINE:
			count += 1
	return count

func _random_cube_with_no_mine(grid: Dictionary, added_mines: Dictionary, start_cube: Vector3i) -> Vector3i:
	var valid_cubes = _remove_invalid_mine_positions(grid, start_cube)
	var random_index: int = randi() % valid_cubes.size()
	var random_cube: Vector3i = valid_cubes[random_index]
	while random_cube in added_mines:
		random_index = randi() % valid_cubes.size()
		random_cube = valid_cubes[random_index]
	return random_cube


func _remove_invalid_mine_positions(grid: Dictionary, start_cube: Vector3i):
	var valid_cubes: Array[Vector3i] = []
	for cube in grid.keys():
		if CellUtils.cube_distance(start_cube, cube) > distance_limit:
			valid_cubes.append(cube)
	return valid_cubes
