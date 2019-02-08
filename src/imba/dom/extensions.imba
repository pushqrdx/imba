var Imba = require("../imba")

# A placeholder tag for enabling the content mechanism.
tag content
	prop name
	
	def ancestor node
		if node?.@context_ === 0
			return node
		ancestor node.@owner_
	
	def setup
		@ancestor = ancestor this
		data && name = data

	def render
		var fragment = Imba.getTagForDom Imba.document.createDocumentFragment
		for node in @ancestor.@children when @name is node.@for or ''
			fragment.appendChild node
		self.before fragment
		self.remove

# An extension to the base tag.
# Provides:
#	1. Access to yielded children through @children property.
#	2. Ability to specify css classes through the class attribute and/or the concise syntax.
#	3. Slot mechanism incl. named slots, through the <content> tag.
#	4. Some new tag functionality like before, after, and remove.
extend tag element
	prop for
	
	def setClass classes
		setAttribute('class', "{getAttribute('class') or ''} {classes}".trim)

	def class
		getAttribute('class')

	def setup
		@children = children
		self
	
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
