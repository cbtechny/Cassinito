extends Node

# Enum for scene IDs
enum ScenesList {
	MAIN_MENU,
	HOW_TO,
	LOAD_SCREEN,
	CASSINO,
	GAME_OVER
}

# Dictionary mapping scene IDs to their paths
const SCENE_PATHS := {
	ScenesList.MAIN_MENU : "res://UI/start_menu.tscn",
	ScenesList.LOAD_SCREEN : "res://UI/loading_scene.tscn",
	ScenesList.HOW_TO : "res://UI/how_to_play.tscn",
	ScenesList.CASSINO : "res://Game/Cassino.tscn",
	ScenesList.GAME_OVER : ""
}

# Store the current scene
var current_scene: Node = null

# Switch to a scene by its ID
func go_to_scene_id( id : int ) -> void:
# Check if the ID is valid
	if not SCENE_PATHS.has( id ):
		push_error( "Invalid scene ID. Check Scene Manager." )
		return

# Get the scene path
	var path := SCENE_PATHS[id] as String
	if path.is_empty():
		push_error( "Scene path is empty" )
		return

# Load the scene
	load_scene( path )

# Load a scene from a given path
func load_scene( path : String ) -> void:
	# Load the scene
	var packed_scene := load( path )
	if not packed_scene is PackedScene:
		push_error( "Failed to load scene: " + path )
		return

 # Free/delete the current scene if it exists
	if current_scene:
		current_scene.free()

# Switch to the new scene
	get_tree().change_scene_to_packed( packed_scene )
