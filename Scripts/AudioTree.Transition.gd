extends AnimationNodeStateMachineTransition

export(int) var range_max

var owner
var parent


func init(_parent):
	
	parent = _parent
	
	parent.connect('on_process', self, 'process')


func process():
	
	pass#disabled = false#not trigger