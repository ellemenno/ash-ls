package ash.fsm
{
	import system.reflection.Type;

	import ash.core.Entity;

	/**
	 * This is a state machine for an entity. The state machine manages a set of states,
	 * each of which has a set of component providers. When the state machine changes the state, it removes
	 * components associated with the previous state and adds components associated with the new state.
	 */
	public class EntityStateMachine
	{
		/**
		 * The entity whose state machine this is
		 */
		public var entity : Entity;

		private var states : Dictionary.<String, EntityState>;
		private var currentState : EntityState;
		private var _currentStateName : String;

		/**
		 * Constructor. Creates an EntityStateMachine.
		 */
		public function EntityStateMachine( entity : Entity ) : void
		{
			this.entity = entity;
			states = new Dictionary.<String, EntityState>();
		}

		/**
		 * Add a state to this state machine.
		 *
		 * @param name The name of this state - used to identify it later in the changeState method call.
		 * @param state The state.
		 * @return This state machine, so methods can be chained.
		 */
		public function addState( name : String, state : EntityState ) : EntityStateMachine
		{
			states[ name ] = state;
			return this;
		}

		/**
		 * Create a new state in this state machine.
		 *
		 * @param name The name of the new state - used to identify it later in the changeState method call.
		 * @return The new EntityState object that is the state. This will need to be configured with
		 * the appropriate component providers.
		 */
		public function createState( name : String ) : EntityState
		{
			var state : EntityState = new EntityState();
			states[ name ] = state;
			return state;
		}

		/**
		 * Change to a new state. The components from the old state will be removed and the components
		 * for the new state will be added.
		 *
		 * @param name The name of the state to change to.
		 */
		public function changeState( name : String ) : void
		{
			var newState : EntityState = states[ name ];
			Debug.assert( newState != null, "Entity state " + name + " doesn't exist" );
			if( newState == currentState )
			{
				newState = null;
				return;
			}
			var toAdd : Dictionary.<Type, IComponentProvider>;
			var type : Type;
			if ( currentState )
			{
				toAdd = new Dictionary.<Type, IComponentProvider>();
				for( type in newState.providers )
				{
					toAdd[ type ] = newState.providers[ type ];
				}
				for( type in currentState.providers )
				{
					var other : IComponentProvider = toAdd[ type ];

					if ( other && other.identifier == currentState.providers[ type ].identifier )
					{
						toAdd.deleteKey( type );
					}
					else
					{
						entity.remove( type );
					}
				}
			}
			else
			{
				toAdd = newState.providers;
			}
			for( type in toAdd )
			{
				entity.add( IComponentProvider( toAdd[ type ] ).getComponent(), type );
			}
			currentState = newState;
		}

		/**
		 * Retrieve the name of the current state
		 */
		public function get currentStateName() : String
		{
			return _currentStateName;
		}
	}
}
