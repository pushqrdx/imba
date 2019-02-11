function iter$(a){ return a ? (a.toArray ? a.toArray() : a) : []; };
var Imba = require("../imba");

Imba.defineTag('content', function(tag){
	tag.prototype.name = function(v){ return this._name; }
	tag.prototype.setName = function(v){ this._name = v; return this; };
	
	tag.prototype.flatten = function (root,nodes){
		if(nodes === undefined) nodes = [];
		if (root instanceof Array) {
			for (var i = 0, items = iter$(root), len = items.length; i < len; i++) {
				this.flatten(items[i],nodes);
			};
		} else {
			nodes.push(root);
		};
		
		return nodes;
	};
	
	tag.prototype.fragment = function (nodes){
		var fragment = Imba.getTagForDom(Imba.document().createDocumentFragment());
		for (var i = 0, items = iter$(this.flatten(nodes)), len = items.length, node; i < len; i++) {
			node = items[i];
			if (!((node instanceof Imba.Tag))) {
				continue;
			};
			if (this._name === node._for || '') {
				fragment.appendChild(node);
			};
		};
		return fragment;
	};
	
	tag.prototype.ancestor = function (node){
		var $1;
		if (($1 = node) && $1._context_ === 0) {
			return node;
		};
		return this.ancestor(node._owner_);
	};
	
	tag.prototype.setup = function (){
		var v_;
		this._ancestor = this.ancestor(this);
		return this.data() && ((this.setName(v_ = this.data()),v_));
	};
	
	tag.prototype.render = function (){
		return this.setChildren(this.fragment(this._ancestor._body));
	};
});

Imba.extendTag('element', function(tag){
	tag.prototype['for'] = function(v){ return this._for; }
	tag.prototype.setFor = function(v){ this._for = v; return this; };
	
	tag.prototype.body = function (content){
		this._body = content;
		return this;
	};
	
	tag.prototype.setClass = function (classes){
		return this.setAttribute('class',("" + (this.getAttribute('class') || '') + " " + classes).trim());
	};
	
	tag.prototype.class = function (){
		return this.getAttribute('class');
	};
	
	tag.prototype.remove = function (node){
		var $1, $2;
		this.dom().remove(($1 = node) && $1._slot_ || node);
		Imba.TagManager.remove(($2 = node) && $2._tag || node,this);
		return this;
	};
	
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
});
