extends Node
class_name Pathfinding

var astar = AStar2D.new()
var tilemap : TileMapLayer
var half_cell_size : Vector2
var used_rect : Rect2i
var original_tile_weights = {}

func _physics_process(_delta: float) -> void:
	update_nav_map()

#Creates navigation map for given tilemap
func create_nav_map(tilemap : TileMapLayer):
	self.tilemap = tilemap
	
	half_cell_size = tilemap.tile_set.tile_size / 2
	used_rect = tilemap.get_used_rect()
	
	var used_tiles = tilemap.get_used_cells()
	
	add_navigation_tiles(used_tiles)
	connect_navigation_tiles(used_tiles)

#Used to enable and disable points on the nav map. For example, if a agent blocks a tile, it will
#become disabled for however many frames
func update_nav_map():
	for point in astar.get_point_ids():
		astar.set_point_disabled(point, false)
	for obstacle in get_tree().get_nodes_in_group("Obstacle"):
		if obstacle is TileMapLayer:
			var tiles = obstacle.get_used_cells()
			for tile in tiles:
				var id = get_id_for_point(tile)
				if astar.has_point(id):
					astar.set_point_disabled(id, true)
		if obstacle is Agent:
			var shape = obstacle.collision_shape.shape
			if shape is CircleShape2D:
				var closest_point_id = astar.get_closest_point(tilemap.local_to_map(obstacle.position))
				var closest_point = tilemap.map_to_local(astar.get_point_position(closest_point_id))
				astar.set_point_disabled(closest_point_id, true)
				#Gets the closest points to the agent, and if they are inside the collision shape,
				#they get disabled
				while obstacle.position.distance_to(closest_point) <= shape.radius:
					astar.set_point_disabled(closest_point_id, true)
					closest_point_id = astar.get_closest_point(tilemap.local_to_map(obstacle.position))
					closest_point = tilemap.map_to_local(astar.get_point_position(closest_point_id))

func add_navigation_tiles(tiles : Array):
	for tile in tiles:
		var id = get_id_for_point(tile)
		var weight = tilemap.get_cell_tile_data(tile).get_custom_data("Weight")
		astar.add_point(id, tile, weight)

func update_navigation_tile(tile):
	var id = get_id_for_point(tile)
	var weight = tilemap.get_cell_tile_data(tile).get_custom_data("Weight")
	astar.add_point(id, tile, weight)

#Connects adjacent tiles, both ones side by side and diagonal ones
func connect_navigation_tiles(tiles : Array):
	for tile in tiles:
		var id = get_id_for_point(tile)
		for x in range(-1, 2):
			for y in range(-1, 2):
				var connection_tile = Vector2i(tile.x + x, tile.y + y)
				var connection_tile_id = get_id_for_point(connection_tile)
				if connection_tile != tile && astar.has_point(connection_tile_id):
					astar.connect_points(id, connection_tile_id, true)

func get_id_for_point(point : Vector2):
	var x = point.x - used_rect.position.x
	var y = point.y - used_rect.position.y
	
	return x + y * used_rect.size.x

func get_path_between_points(start : Vector2, end : Vector2, allow_partial_path : bool):
	var start_tile = tilemap.local_to_map(start)
	var end_tile = tilemap.local_to_map(end)
	
	var start_tile_id = get_id_for_point(start_tile)
	var end_tile_id = get_id_for_point(end_tile)
	
	if !astar.has_point(start_tile_id) || !astar.has_point(end_tile_id):
		return null
	
	var global_points = []
	
	for point in astar.get_point_path(start_tile_id, end_tile_id, allow_partial_path):
		global_points.append(tilemap.map_to_local(point))
	
	return global_points
