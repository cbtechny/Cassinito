extends Node

enum ScenesList {
	
	MAIN_MENU,
	HOW_TO,
	LOAD_SCREEN,
	CASSINO,
	GAME_OVER
	
}

const SCENE_PATHS := {
	
	ScenesList.MAIN_MENU : "res://UI/start_menu.tscn",
	ScenesList.LOAD_SCREEN : "res://UI/loading_scene.tscn",
	ScenesList.HOW_TO : "res://UI/how_to_play.tscn",
	ScenesList.CASSINO : "res://Game/Cassino.tscn",
	ScenesList.GAME_OVER : ""
}

var current_scene : Node = null

func go_to_scene_id( id : int ) -> void:

	if not SCENE_PATHS.has( id ):
		push_error( "Invalid scene ID. Check Scene Manager." ) 
		return

	var path := SCENE_PATHS[ id ] as String

	if path == "" or path == null:
		push_error( "Scene path is empty" )
		return
		
	load_scene(  SCENE_PATHS[ id ]  )

func load_scene( path: String ) -> void:

	var packed_scene := load( path ) as PackedScene

	if packed_scene == null:
		push_error( "Scene Manager failed to load scene." )
		return

	if current_scene:
		current_scene.queue_free()

	get_tree().change_scene_to_packed( packed_scene )
	current_scene = get_tree().current_scene
