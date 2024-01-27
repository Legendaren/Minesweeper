extends TileMap

const LAYER: int = 0
const SOURCE_ID: int = 2

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

const RADIUS_LIMIT: int = 10
const START_CUBE := Vector3i(0, 0, 0)

const MINE_COUNT = 50

const MINE_COUNT_TO_ATLAS = {
	0: EMPTY,
	1: ONE, 2: TWO, 3: THREE,
	4: FOUR, 5: FIVE, 6: SIX
}

var cells: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_empty_grid(START_CUBE, RADIUS_LIMIT)
	add_mines_to_grid(MINE_COUNT)
	update_mine_count()
	

func create_empty_grid(start: Vector3i, radius_limit: int) -> void:
	var stack = []
	stack.append(start)
	while not stack.is_empty():
		var cube = stack.pop_back()
		var oddr = CellUtils.cube_to_oddr(cube)
		set_cell(LAYER, oddr, SOURCE_ID, HIDDEN)
		cells[cube] = CellComponent.new(cube)
		var neighbors: Array[Vector3i] = CellUtils.cube_neighbors(cube)
		for n in neighbors:
			if n not in cells and CellUtils.cube_distance(start, n) < radius_limit:
				stack.append(n)
				

func add_mines_to_grid(mines: int) -> void:
	var added_mines: Dictionary = {}
	for i in range(mines):
		var keys: Array = cells.keys()
		var random_index: int = randi() % keys.size()
		while random_index in added_mines:
			random_index = randi() % keys.size()
		var random_cube: Vector3i = keys[random_index]
		var random_cell: CellComponent = cells[random_cube]
		random_cell.set_as_mine()
		added_mines[random_index] = true


func update_mine_count() -> void:
	for cell: CellComponent in cells.values():
		if cell.cell_state == Enums.CellState.MINE:
			continue
		cell.neighbor_mine_count = calculate_neighbor_mine_count(cell)
		if cell.neighbor_mine_count > 0:
			cell.cell_state = Enums.CellState.NUMBER


func calculate_neighbor_mine_count(cell: CellComponent) -> int:
	var neighbor_cubes: Array[Vector3i] = CellUtils.cube_neighbors(cell.pos)
	var count: int = 0
	for cube in neighbor_cubes:
		if cube in cells and cells[cube].cell_state == Enums.CellState.MINE:
			count += 1
	return count

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
		

func update_cell(cell_pos: Vector2i, atlas_pos: Vector2i) -> void:
	set_cell(LAYER, cell_pos, SOURCE_ID, atlas_pos)


func reveal_cell(cell: CellComponent) -> void:
	cell.reveal_cell()
	var oddr: Vector2i = CellUtils.cube_to_oddr(cell.pos)
	if cell.cell_state == Enums.CellState.MINE:
		update_cell(oddr, RED_MINE)
	else:
		update_cell(oddr, MINE_COUNT_TO_ATLAS[cell.neighbor_mine_count])


func reveal_connected_empty_cells(cell: CellComponent) -> void:
	var stack: Array[Vector3i] = [cell.pos]
	var visited: Dictionary = {}
	while stack:
		var popped_cube: Vector3i = stack.pop_back()
		var popped_cell : CellComponent = cells[popped_cube]
		if popped_cube in visited:
			continue
		if popped_cell.cell_state == Enums.CellState.MINE:
			continue
			
		reveal_cell(popped_cell)

		if popped_cell.neighbor_mine_count > 0:
			continue
		
		visited[popped_cube] = true
		for neighbor_cube: Vector3i in CellUtils.cube_neighbors(popped_cube):
			if neighbor_cube in cells:
				stack.append(neighbor_cube)

func select_cell(cell: CellComponent) -> void:
	if cell.is_revealed or cell.is_flagged:
		return
		
	var oddr: Vector2i = CellUtils.cube_to_oddr(cell.pos)
		
	reveal_cell(cell)
	print(cell.cell_state)
	if cell.cell_state == Enums.CellState.EMPTY:
		reveal_connected_empty_cells(cell)



func flag_cell(cell: CellComponent) -> void:
	if cell.is_revealed:
		return
		
	var oddr: Vector2i = CellUtils.cube_to_oddr(cell.pos)
	if cell.is_flagged:
		update_cell(oddr, HIDDEN)
	else:
		update_cell(oddr, FLAG)
	cell.flag_cell()
