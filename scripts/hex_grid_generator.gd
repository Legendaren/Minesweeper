extends Node
class_name HexGridGenerator

## Generate a hex grid in a Dictionary
## Key = cube coordinate
## Value = object of type CellComponent

func generate_grid(start: Vector3i, radius_limit: int, mines: int) -> Dictionary:
	var empty_grid: Dictionary = _create_empty_grid(start, radius_limit)
	var grid_with_mines: Dictionary = _add_mines_to_grid(empty_grid, mines)
	_update_mine_count(grid_with_mines)
	return grid_with_mines
	

func _create_empty_grid(start: Vector3i, radius_limit: int) -> Dictionary:
	var grid = {}
	var stack = []
	stack.append(start)
	while not stack.is_empty():
		var cube = stack.pop_back()
		var oddr = CellUtils.cube_to_oddr(cube)
		grid[cube] = CellComponent.new(cube)
		var neighbors: Array[Vector3i] = CellUtils.cube_neighbors(cube)
		for n in neighbors:
			if n not in grid and CellUtils.cube_distance(start, n) < radius_limit:
				stack.append(n)
	return grid


func _add_mines_to_grid(grid: Dictionary, mines: int) -> Dictionary:
	var added_mines := {}
	var new_grid := grid.duplicate(true)
	for i in range(mines):
		var keys := grid.keys()
		var random_index: int = randi() % keys.size()
		while random_index in added_mines:
			random_index = randi() % keys.size()
		var random_cube: Vector3i = keys[random_index]
		var random_cell: CellComponent = grid[random_cube]
		random_cell.set_cell_state(Enums.CellState.MINE)
		added_mines[random_index] = true
	return new_grid


func _update_mine_count(grid: Dictionary) -> void:
	for cell: CellComponent in grid.values():
		if cell.cell_state == Enums.CellState.MINE:
			continue
		cell.neighbor_mine_count = _calculate_neighbor_mine_count(grid, cell)
		if cell.neighbor_mine_count > 0:
			cell.cell_state = Enums.CellState.NUMBER


static func _calculate_neighbor_mine_count(grid: Dictionary, cell: CellComponent) -> int:
	var neighbor_cubes: Array[Vector3i] = CellUtils.cube_neighbors(cell.pos)
	var count: int = 0
	for cube in neighbor_cubes:
		if cube in grid and grid[cube].cell_state == Enums.CellState.MINE:
			count += 1
	return count
