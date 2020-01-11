extends AnimationNodeStateMachine

const camera_rig_track_path = '../../Perspective'

export(String) var statemachine

var node_name
var owner
var parent
var parameters
var transitions = []
#var nodes = []
#
#var current_node = get_start_node()
#
#signal state_starting
#signal travel_starting