extends GridContainer


@export var ROW_COUNT: int
@export var COLUMN_COUNT: int
@export var MINE_COUNT: int
@export var cell_grid_generator: CellGridGenerator

var cells : Array[Array] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus.mine_revealed.connect(on_mine_reveal)
	
	var grid: Array[Array] = cell_grid_generator.generate_empty_grid(ROW_COUNT, COLUMN_COUNT)
	cells = grid
	for i in range(MINE_COUNT):
		cell_grid_generator.add_mine_to_grid(grid)
		
	for row in grid:
		for cell in row:
			add_child(cell)
			cell.init_cell()


func on_mine_reveal(_cell: CellComponent) -> void:
	reveal_all_cells()
	
	
func reveal_all_cells() -> void:
	for row in cells:
		for cell: CellComponent in row:
			cell.reveal_cell()
