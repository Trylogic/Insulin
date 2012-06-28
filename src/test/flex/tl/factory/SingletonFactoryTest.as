package tl.factory
{

	import org.flexunit.asserts.assertEquals;

	public class SingletonFactoryTest
	{
		[Test]
		public function testSingleton() : void
		{
			assertEquals( SingletonFactory.makeInstance( SingletonFactoryTest ), SingletonFactory.makeInstance( SingletonFactoryTest ) );
		}
	}
}
