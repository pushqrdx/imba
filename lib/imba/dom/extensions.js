function iter$(a){ return a ? (a.toArray ? a.toArray() : a) : []; };
function len$(a){
	return a && (a.len instanceof Function ? a.len() : a.length) || 0;
};
var Imba = require("../imba");

// A placeholder tag for enabling the content mechanism.
Imba.defineTag('content', function(tag){
	tag.prototype.name = function(v){ return this._name; }
	tag.prototype.setName = function(v){ this._name = v; return this; };
	
	// Gets the top most Imba tag housing this content slot.
	tag.prototype.ancestor = function (node){
		var $1;
		if (($1 = node) && $1._context_ === 0) {
			return node;
		};
		return this.ancestor(node._owner_);
	};
	
	// Hooks the content grand parent.
	tag.prototype.setup = function (){
		var v_;
		this._parent = this.ancestor(this);
		this.data() && ((this.setName(v_ = this.data()),v_));
		return this._magic = '2f3a4fccca6406e35bcf33e92dd93135';
	};
});

// An extension to the base tag.
// Provides:
//	1. Access to yielded children through @children property.
//	2. Ability to specify css classes through the class attribute and/or the concise syntax.
//	3. Slot mechanism incl. named slots, through the <content> tag.
//	4. Some new tag functionality like before, after, and remove.
Imba.extendTag('element', function(tag){
	tag.prototype['for'] = function(v){ return this._for; }
	tag.prototype.setFor = function(v){ this._for = v; return this; };
	
	tag.prototype.before = function (node){
		if ((typeof node=='string'||node instanceof String)) {
			this.dom().before(Imba.document().createTextNode(node));
		} else if (node) {
			this.dom().before(node._slot_ || node);
			Imba.TagManager.insert(node._tag || node,this);
		};
		return this;
	};
	
	tag.prototype.after = function (node){
		if ((typeof node=='string'||node instanceof String)) {
			this.dom().after(Imba.document().createTextNode(node));
		} else if (node) {
			this.dom().after(node._slot_ || node);
			Imba.TagManager.insert(node._tag || node,this);
		};
		return this;
	};
	
	tag.prototype.remove = function (node){
		var $1, $2;
		this.dom().remove(($1 = node) && $1._slot_ || node);
		Imba.TagManager.remove(($2 = node) && $2._tag || node,this);
		return this;
	};
	
	tag.prototype.setClass = function (classes){
		return this.setAttribute('class',("" + (this.getAttribute('class') || '') + " " + classes).trim());
	};
	
	tag.prototype.class = function (){
		return this.getAttribute('class');
	};
	
	tag.prototype.setup = function (){
		this._children = this.children();
		return this;
	};
	
	tag.prototype.end = function (){
		this.setup();
		this.commit(0);
		this.fill(); // at this stage we have enough info.
		this.end = Imba.Tag.end;
		return this;
	};
	
	tag.prototype.fill = function (slot,nodes){
		if (!(slot && nodes)) {
			// if this is a content tag, get children
			// associated with it and call this method
			// to fill with them.
			if (this._magic === '2f3a4fccca6406e35bcf33e92dd93135') {
				var nodes = this._parent._children;
				if (len$(nodes) > 0) {
					this.fill(this,nodes);
				};
			};
			return;
		};
		
		var name = slot._name || '';
		var fragment = Imba.getTagForDom(Imba.document().createDocumentFragment());
		
		for (var i = 0, items = iter$(nodes), len = items.length, node; i < len; i++) {
			node = items[i];
			var target = node._for || '';
			
			if (target === name) {
				fragment.appendChild(node);
			};
		};
		
		slot.before(fragment);
		slot.remove();
		return this;
	};
});
