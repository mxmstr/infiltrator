class_name TrenchBroomTag
extends Resource

enum TagMatchType {
	TEXTURE,
	CONTENT_FLAG,
	SURFACE_FLAG,
	SURFACE_PARAM,
	CLASSNAME
}

@export var tag_name: String : String
@export var tag_attributes : Array # (Array, String)
@export var tag_match_type: TagMatchType : int
@export var tag_pattern: String : String
@export var texture_name: String : String
