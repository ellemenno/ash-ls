
package
{

	import loom.Application;

	import pixeldroid.bdd.Spec;
	import pixeldroid.bdd.reporters.AnsiReporter;
	import pixeldroid.bdd.reporters.JunitReporter;

	import AshSpec;
	import EntitySpec;


	public class AshTest extends Application
	{
		override public function run():void
		{
			AshSpec.describe();
			EntitySpec.describe();

			Spec.addReporter(new AnsiReporter());
			Spec.addReporter(new JunitReporter());
			Spec.execute();
		}
	}
}