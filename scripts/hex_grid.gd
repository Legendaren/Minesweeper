extends TileMap
class_name HexGrid

const LAYER := 0
const SOURCE_ID := 2

const RADIUS_LIMIT := 10
const START_CUBE := Vector3i(0, 0, 0)
const MINE_COUNT := 50

const ONE := Vector2i(0, 0)
const TWO := Vector2i(1, 0)
const THREE := Vector2i(2, 0)
const RED_MINE := Vector2(3, 0)
const FOUR := Vector2i(0, 1)
const FIVE := Vector2i(1, 1)
const SIX := Vector2i(2, 1)
const EMPTY := Vector2i(3, 1)
const FLAG := Vector2i(0, 2)
const HIDDEN := Vector2i(1, 2)
const MINE := Vector2i(2, 2)
const MINE_COUNT_TO_ATLAS := {
	0: EMPTY,
	1: ONE, 2: TWO, 3: THREE,
	4: FOUR, 5: FIVE, 6: SIX
}

var cells := {}
var is_mine_revealed := false
@onready var hex_grid_generator: HexGridGenerator = $"Hex Grid Generator"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.mine_revealed.connect(_on_any_mine_reveal)
	cells = hex_grid_generator.generate_grid(START_CUBE, RADIUS_LIMIT, MINE_COUNT)
	_display_grid()


func _on_any_mine_reveal(cell: CellComponent):
	is_mine_revealed = true

func _display_grid() -> void:
	for cell: CellComponent in cells.values():
		var oddr: Vector2i = CellUtils.cube_to_oddr(cell.pos)
		if not cell.is_revealed:
			_set_cell_v2(oddr, HIDDEN)
		elif cell.cell_state == Enums.CellState.MINE:
			_set_cell_v2(oddr, RED_MINE)
		else:
			_set_cell_v2(oddr, MINE_COUNT_TO_ATLAS[cell.neighbor_mine_count])
	

func _input(event: InputEvent) -> void:	
	var mouse_pos: Vector2 = get_global_mouse_position()
	var cell_pos: Vector2i = local_to_map(mouse_pos)
	var cell_source_id: int = get_cell_source_id(LAYER, cell_pos)
	if cell_source_id == -1:
		return
		
	var cell_cube: Vector3i =  CellUtils.oddr_to_cube(cell_pos)
	var cell: CellComponent = cells[cell_cube]
	if event.is_action_pressed("select_cell"):
		select_cell(cell)
	if event.is_action_pressed("flag_cell"):
		flag_cell(cell)


func _set_cell_v2(cell_pos: Vector2i, atlas_pos: Vector2i) -> void:
	set_cell(LAYER, cell_pos, SOURCE_ID, atlas_pos)


func _reveal_cell(cell: CellComponent) -> void:
	cell.reveal_cell()
	var oddr: Vector2i = CellUtils.cube_to_oddr(cell.pos)
	if cell.cell_state == Enums.CellState.MINE:
		_set_cell_v2(oddr, RED_MINE)
		EventBus.mine_revealed.emit(cell)
	else:
		_set_cell_v2(oddr, MINE_COUNT_TO_ATLAS[cell.neighbor_mine_count])


func _reveal_connected_empty_cells(cell: CellComponent) -> void:
	var stack: Array[Vector3i] = [cell.pos]
	var visited: Dictionary = {}
	while stack:
		var popped_cube: Vector3i = stack.pop_back()
		var popped_cell : CellComponent = cells[popped_cube]
		if popped_cube in visited:
			continue
		if popped_cell.cell_state == Enums.CellState.MINE:
			continue
			
		_reveal_cell(popped_cell)

		if popped_cell.neighbor_mine_count > 0:
			continue
		
		visited[popped_cube] = true
		for neighbor_cube: Vector3i in CellUtils.cube_neighbors(popped_cube):
			if neighbor_cube in cells:
				stack.append(neighbor_cube)


func select_cell(cell: CellComponent) -> void:
	if is_mine_revealed:
		return
	if cell.is_revealed or cell.is_flagged:
		return
		
	var oddr: Vector2i = CellUtils.cube_to_oddr(cell.pos)
	_reveal_cell(cell)
	if cell.cell_state == Enums.CellState.EMPTY:
		_reveal_connected_empty_cells(cell)


func flag_cell(cell: CellComponent) -> void:
	if is_mine_revealed:
		return
	if cell.is_revealed:
		return
		
	var oddr: Vector2i = CellUtils.cube_to_oddr(cell.pos)
	if cell.is_flagged:
		_set_cell_v2(oddr, HIDDEN)
	else:
		_set_cell_v2(oddr, FLAG)
	cell.flag_cell()
