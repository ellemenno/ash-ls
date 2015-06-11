package ash.core
{
	import system.reflection.Type;

	/**
	 * The default class for managing a NodeList. This class creates the NodeList and adds and removes
	 * nodes to/from the list as the entities and the components in the engine change.
	 *
	 * It uses the basic entity matching pattern of an entity system - entities are added to the list if
	 * they contain components matching all the public properties of the node class.
	 */
	public class ComponentMatchingFamily implements IFamily
	{
		private var nodes : NodeList;
		private var entities : Dictionary.<Entity, Node>;
		private var familyType : Type;
		private var components : Dictionary.<Type, String>;
		private var nodePool : NodePool;
		private var engine : Engine;

		/**
		 * The constructor. Creates a ComponentMatchingFamily to provide a NodeList for the
		 * given node class.
		 */
		public function ComponentMatchingFamily()
		{
		}

		/**
		 * Initialises the class. Creates the nodelist and other tools. Analyses the node to determine
		 * what component types the node requires.
		 *
		 * @param familyType The type of node to create and manage a NodeList for.
		 * @param engine The engine that this family is managing the NodeList for.
		 */
		public function init( familyType : Type, engine : Engine ) : void
		{
			this.familyType = familyType;
			this.engine = engine;

			nodes = new NodeList();
			entities = new Dictionary.<Entity, Node>();
			components = new Dictionary.<Type, String>();
			nodePool = new NodePool( familyType, components );

			nodePool.dispose( nodePool.getNode() ); // create a dummy instance to ensure describeType works.

			for each (var fieldName : String in familyType.getFieldAndPropertyList())
			{
				var fieldInfo : FieldInfo = familyType.getFieldInfoByName(fieldName);
				if (fieldName != "entity" && fieldName != "previous" && fieldName != "next" && fieldName != "NaN")
				{
					var type:Type = fieldInfo.getMemberType();
					components[type] = fieldName;
				}
			}
		}

		/**
		 * The nodelist managed by this family. This is a reference that remains valid always
		 * since it is retained and reused by Systems that use the list. i.e. we never recreate the list,
		 * we always modify it in place.
		 */
		public function get nodeList() : NodeList
		{
			return nodes;
		}

		/**
		 * Called by the engine when an entity has been added to it. We check if the entity should be in
		 * this family's NodeList and add it if appropriate.
		 */
		public function newEntity( entity : Entity ) : void
		{
			addIfMatch( entity );
		}

		/**
		 * Called by the engine when a component has been added to an entity. We check if the entity is not in
		 * this family's NodeList and should be, and add it if appropriate.
		 */
		public function componentAddedToEntity( entity : Entity, componentClass : Type ) : void
		{
			addIfMatch( entity );
		}

		/**
		 * Called by the engine when a component has been removed from an entity. We check if the removed component
		 * is required by this family's NodeList and if so, we check if the entity is in this this NodeList and
		 * remove it if so.
		 */
		public function componentRemovedFromEntity( entity : Entity, componentClass : Type ) : void
		{
			if( components[componentClass] )
			{
				removeIfMatch( entity );
			}
		}

		/**
		 * Called by the engine when an entity has been rmoved from it. We check if the entity is in
		 * this family's NodeList and remove it if so.
		 */
		public function removeEntity( entity : Entity ) : void
		{
			removeIfMatch( entity );
		}

		/**
		 * If the entity is not in this family's NodeList, tests the components of the entity to see
		 * if it should be in this family's NodeList and adds it if so.
		 */
		private function addIfMatch( entity : Entity ) : void
		{
			if( !entities[entity] )
			{
				var componentClass : Type;
				for ( componentClass in components )
				{
					if ( !entity.has( componentClass ) ) return;
				}

				var node : Node = nodePool.getNode();
				var nodeClass : Type = node.getType();
				node.entity = entity;
				var fieldInfo : FieldInfo;
				for ( componentClass in components )
				{
					fieldInfo = nodeClass.getFieldInfoByName( components[componentClass] );
					fieldInfo.setValue( node, entity.fetch( componentClass ) );
				}

				entities[entity] = node;
				nodes.add( node );
			}
		}

		/**
		 * Removes the entity if it is in this family's NodeList.
		 */
		private function removeIfMatch( entity : Entity ) : void
		{
			if( entities[entity] )
			{
				var node : Node = entities[entity];
				entities.deleteKey( entity );
				nodes.remove( node );
				if( engine.updating )
				{
					nodePool.cache( node );
					engine.updateComplete += releaseNodePoolCache;
				}
				else
				{
					nodePool.dispose( node );
				}
			}
		}

		/**
		 * Releases the nodes that were added to the node pool during this engine update, so they can
		 * be reused.
		 */
		private function releaseNodePoolCache() : void
		{
			engine.updateComplete -= releaseNodePoolCache;
			nodePool.releaseCache();
		}

		/**
		 * Removes all nodes from the NodeList.
		 */
		public function cleanUp() : void
		{
			for( var node : Node = nodes.head; node; node = node.next )
			{
				entities.deleteKey(node.entity);
			}
			nodes.removeAll();
		}
	}
}
