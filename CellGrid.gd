extends GridContainer


const ROW_COUNT = 16
const COLUMN_COUNT = 16
const MINE_COUNT = 10

var cells : Array[Array] = []
@export var cell_grid_generator: CellGridGenerator

# Called when the node enters the scene tree for the first time.
func _ready():
	var grid: Array[Array] = cell_grid_generator.generate_empty_grid(ROW_COUNT, COLUMN_COUNT)
	cells = grid
	for i in range(MINE_COUNT):
		cell_grid_generator.add_mine_to_grid(grid)
		
	for row in grid:
		for cell in row:
			add_child(cell)
			cell.init_cell()
