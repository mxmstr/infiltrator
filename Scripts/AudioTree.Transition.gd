extends AnimationNodeStateMachineTransition

@export var range_max: int

var owner
var parent


func init(_parent):
	
	parent = _parent
	
	parent.connect('on_process',Callable(self,'process'))


func process():
	
	pass#disabled = false#not trigger
