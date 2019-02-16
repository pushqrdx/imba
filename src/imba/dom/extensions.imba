var Imba = require("../imba")

tag content
	prop name

	def flatten root, nodes = []
		if root isa Array
			for node in root
				flatten node, nodes
		else 
			nodes.push root
			
		return nodes
	
	def fragment nodes
		var fragment = Imba.getTagForDom Imba.document.createDocumentFragment
		for node in flatten nodes 
			unless node isa Imba.Tag 
				continue
			if @name is node.@for or ''
				fragment.appendChild node
		fragment
	
	def ancestor node
		if node?.@context_ === 0
			return node
		ancestor node.@owner_
	
	def setup
		@ancestor = ancestor this
		data && name = data

	def render
		setChildren fragment @ancestor.@body

extend tag element
	prop for

	def body content
		@body = content
		self

	def setClass classes
		for flag in classes.split ' '
			self.flag flag
		self
			
	def class
		getAttribute('class')

	def remove node
		dom.remove(node?.@slot_ or node)
		Imba.TagManager.remove(node?.@tag or node, self)
		self
		
	def before node
		if node isa String
			dom.before(Imba.document.createTextNode(node))
		elif node
			dom.before(node.@slot_ or node)
			Imba.TagManager.insert(node.@tag or node, self)
		self
		
	def after node
		if node isa String
			dom.after(Imba.document.createTextNode(node))
		elif node
			dom.after(node.@slot_ or node)
			Imba.TagManager.insert(node.@tag or node, self)
		self
