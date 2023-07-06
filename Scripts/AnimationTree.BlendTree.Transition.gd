@tool
extends AnimationNodeTransition

var owner
var parent
var parameters


func _evaluate(target, method, args):
	
	var playback = owner.get(parameters + 'playback')
	
	return owner.owner.get_node(target).callv(method, args)


func __ready(_owner, _parent, _parameters):
	
	return
	
	owner = _owner
	parent = _parent
	parameters = _parameters
	
	owner.connect('on_process',Callable(self,'__process'))


func __process(delta):
	
	var best_input
	var best_score = 0
	
	for input in range(input_count):
		
		owner.set(parameters + 'input_' + str(input) + '/auto_advance', false)
		
		var input_name = owner.get(parameters + 'input_' + str(input) + '/name')
		var data = owner.get(parameters + 'input_' + str(input) + '/data')
		var score = 0
		
		for key in data:
			
			var eval = data[key]
			
			if _evaluate(eval.target, eval.method, eval.args):
				score += eval.score
		
		if score > best_score:
			
			best_score = score
			best_input = input
	
	
	owner.set(parameters + 'input_' + str(best_input) + '/auto_advance', true)
