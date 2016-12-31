package
{
	import ash.core.Entity;

	import pixeldroid.bdd.Spec;
	import pixeldroid.bdd.Thing;


	public static class EntitySpec
	{
		private static const it:Thing = Spec.describe('Entity');

		public static function describe():void
		{
			it.should('return a reference to the Entity when adding components', return_entity_on_add);
			it.should('store and retrieve components of differing types', store_and_retrieve_multitypes);
			it.should('replace components of the same type', replace_when_types_match);
			it.should('store base and extended components', store_base_and_extended);
			it.should('store extended components as base type', store_by_base_type);
			it.should('retrieve null when no components match given type', retrieve_null_when_no_components);
			it.should('retrieve all components', retrieve_components);
			it.should('report false when no components match given type', report_component_no_match);
			it.should('report true when at least one component matches given type', report_component_match);
			it.should('remove components', remove_components);
			it.should('trigger delegates when adding components', trigger_delegates_on_component_add);
			it.should('trigger delegates when removing components', trigger_delegates_on_component_remove);
			it.should('have a name by default', provide_default_name);
			it.should('keep a given name', keep_given_names);
			it.should('allow its name to be changed', allow_name_changes);
			it.should('trigger delegates when changing name', trigger_delegates_on_name_change);
		}


		private static function return_entity_on_add():void
		{
			var entity:Entity = new Entity();
			var component:MockComponent = new MockComponent();
			var e:Entity = entity.add(component);
			it.expects(e).toEqual(entity);
		}

		private static function store_and_retrieve_multitypes():void
		{
			var entity:Entity = new Entity();
			var component:MockComponent = new MockComponent();
			entity.add(component);
			var component2:MockComponent2 = new MockComponent2();
			entity.add(component2);
			it.expects(entity.fetch(MockComponent)).toEqual(component);
			it.expects(entity.fetch(MockComponent2)).toEqual(component2);
		}

		private static function replace_when_types_match():void
		{
			var entity:Entity = new Entity();
			var component:MockComponent = new MockComponent();
			entity.add(component);
			var component2:MockComponent = new MockComponent();
			entity.add(component2);
			it.expects(component).not.toEqual(component2);
			it.expects(entity.fetch(MockComponent)).toEqual(component2);
		}

		private static function store_base_and_extended():void
		{
			var entity:Entity = new Entity();
			var component:MockComponent = new MockComponent();
			entity.add(component);
			var component2:MockComponentExtended = new MockComponentExtended();
			entity.add(component2);
			it.expects(entity.fetch(MockComponent)).toEqual(component);
			it.expects(entity.fetch(MockComponentExtended)).toEqual(component2);
		}

		private static function store_by_base_type():void
		{
			var entity:Entity = new Entity();
			var component:MockComponentExtended = new MockComponentExtended();
			entity.add(component, MockComponent);
			it.expects(entity.fetch(MockComponent)).toEqual(component);
			it.expects(entity.fetch(MockComponentExtended)).toBeNull();
		}

		private static function retrieve_null_when_no_components():void
		{
			var entity:Entity = new Entity();
			it.expects(entity.fetch(MockComponent)).toBeNull();
		}

		private static function retrieve_components():void
		{
			var entity:Entity = new Entity();
			var component:MockComponent = new MockComponent();
			entity.add(component);
			var component2:MockComponent2 = new MockComponent2();
			entity.add(component2);
			var all:Vector.<Object> = entity.fetchAll();
			it.expects(all.length).toEqual(2);
			it.expects(all).toContain(component);
			it.expects(all).toContain(component2);
		}

		private static function report_component_no_match():void
		{
			var entity:Entity = new Entity();
			it.expects(entity.has(MockComponent)).toBeFalsey();
			var component:MockComponent = new MockComponent();
			entity.add(component);
			it.expects(entity.has(MockComponent2)).toBeFalsey();
		}

		private static function report_component_match():void
		{
			var entity:Entity = new Entity();
			var component:MockComponent = new MockComponent();
			entity.add(component);
			it.expects(entity.has(MockComponent)).toBeTruthy();
			var component2:MockComponent = new MockComponent();
			entity.add(component2);
			it.expects(entity.has(MockComponent)).toBeTruthy();
		}

		private static function remove_components():void
		{
			var entity:Entity = new Entity();
			var component:MockComponent = new MockComponent();
			entity.add(component);
			entity.remove(MockComponent);
			it.expects(entity.has(MockComponent)).toBeFalsey();
			var all:Vector.<Object> = entity.fetchAll();
			it.expects(all.length).toEqual(0);
		}

		private static function trigger_delegates_on_component_add():void
		{
			var entity:Entity = new Entity();
			var component:MockComponent = new MockComponent();
			var delegateCalled:Boolean = false;
			entity.componentAdded += function(owner:Entity, flavor:Type) {
				delegateCalled = true;
				it.expects(owner).toEqual(entity);
				it.expects(flavor).toEqual(MockComponent);
			};
			entity.add(component);
			it.expects(delegateCalled).toBeTruthy();
		}

		private static function trigger_delegates_on_component_remove():void
		{
			var entity:Entity = new Entity();
			var component:MockComponent = new MockComponent();
			var delegateCalled:Boolean = false;
			entity.add(component);
			entity.componentRemoved += function(owner:Entity, flavor:Type) {
				delegateCalled = true;
				it.expects(owner).toEqual(entity);
				it.expects(flavor).toEqual(MockComponent);
			};
			entity.remove(MockComponent);
			it.expects(delegateCalled).toBeTruthy();
		}

		private static function provide_default_name():void
		{
			var entity:Entity = new Entity();
			it.expects(entity.name).not.toBeEmpty();
		}

		private static function keep_given_names():void
		{
			var customName:String = 'custom name';
			var entity:Entity = new Entity(customName);
			it.expects(entity.name).toEqual(customName);
		}

		private static function allow_name_changes():void
		{
			var name:String = 'first choice';
			var entity:Entity = new Entity(name);
			var name2:String = 'second choice';
			entity.name = name2;
			it.expects(entity.name).toEqual(name2);
		}

		private static function trigger_delegates_on_name_change():void
		{
			var name:String = 'first choice';
			var entity:Entity = new Entity(name);
			var delegateCalled:Boolean = false;
			var name2:String = 'second choice';
			entity.nameChanged += function(owner:Entity, oldName:String) {
				delegateCalled = true;
				it.expects(owner).toEqual(entity);
				it.expects(oldName).toEqual(name);
				it.expects(owner.name).toEqual(name2);
			};
			entity.name = name2;
			it.expects(delegateCalled).toBeTruthy();
		}
	}


	class MockComponent
	{
		public var value:Number;
	}

	class MockComponent2
	{
		public var value:Number;
	}

	class MockComponentExtended extends MockComponent
	{
		public var other:Number;
	}
}
