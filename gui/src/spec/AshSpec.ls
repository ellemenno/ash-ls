package
{
	import ash.core.Engine;

	import pixeldroid.bdd.Spec;
	import pixeldroid.bdd.Thing;


	public static class AshSpec
	{
		private static const it:Thing = Spec.describe('Ash');

		public static function describe():void
		{
			it.should('be versioned', be_versioned);
		}


		private static function be_versioned():void
		{
			it.expects(Engine.version).toPatternMatch('(%d+).(%d+).(%d+)', 3);
		}
	}
}
