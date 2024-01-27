extends GridContainer


@export var ROW_COUNT: int
@export var COLUMN_COUNT: int
@export var MINE_COUNT: int
@export var cell_grid_generator: CellGridGenerator

var cells : Array[Array] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus.mine_revealed.connect(on_mine_reveal)
	EventBus.empty_cell_revealed.connect(on_empty_cell_reveal)
	
	var grid: Array[Array] = cell_grid_generator.generate_empty_grid(ROW_COUNT, COLUMN_COUNT)
	cells = grid
	for i in range(MINE_COUNT):
		cell_grid_generator.add_mine_to_grid(grid)
		
	for i in range(grid.size()):
		var row = grid[i]
		for j in range(row.size()):
			var cell = row[j]
			add_child(cell)
			cell.init_cell(i, j)


func on_mine_reveal(_cell: CellComponent) -> void:
	reveal_all_cells()
	
	
func on_empty_cell_reveal(cell: CellComponent) -> void:
	var connected_empty_cells = connected_neighbor_empty_cells(cells, cell.row, cell.column)
	for cell_pos in connected_empty_cells:
		var empty_cell: CellComponent = cells[cell_pos[0]][cell_pos[1]]
		empty_cell.reveal_cell()
	
	
func reveal_all_cells() -> void:
	for row in cells:
		for cell: CellComponent in row:
			cell.reveal_cell()


func neighbor_empty_cells(grid: Array[Array], row: int, col: int) -> Array:
	var neighbor_cells: Array = CellUtils.neighbor_positions(grid, row, col)
	var empty_cells: Array = []
	for pos in neighbor_cells:
		var p_row: int = pos[0]
		var p_col: int = pos[1]
		var neighbor_cell: CellComponent = grid[p_row][p_col]
		if neighbor_cell.cell_state == Enums.CellState.EMPTY:
			empty_cells.append(pos)
		elif neighbor_cell.cell_state == Enums.CellState.NUMBER:
			empty_cells.append(pos)
	return empty_cells
	

func connected_neighbor_empty_cells(grid: Array[Array], row: int, col: int) -> Array:
	var connected_cells := {}
	var neighbor_queue = []
	var neighbor_empty_cells: Array = neighbor_empty_cells(grid, row, col)
	neighbor_queue.append_array(neighbor_empty_cells)
			
	while not neighbor_queue.is_empty():
		var neighbor_pos = neighbor_queue.pop_back()
		var neighbor_str = "%d,%d" % [neighbor_pos[0], neighbor_pos[1]]
		if not connected_cells.has(neighbor_str):
			connected_cells[neighbor_str] = neighbor_pos
			if not cells[neighbor_pos[0]][neighbor_pos[1]].cell_state == Enums.CellState.NUMBER:
				var nested_connected_neighbor = neighbor_empty_cells(grid, neighbor_pos[0], neighbor_pos[1])
				neighbor_queue.append_array(nested_connected_neighbor)

	var connected_cells_arr = []
	for cell_str in connected_cells:
		connected_cells_arr.append(connected_cells[cell_str])
	return connected_cells_arr
