package tl.ioc
{

	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.media.Sound;

	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertTrue;

	import tl.factory.SingletonFactory;

	public class IOCHelperTest
	{
		[Inject]
		public var sprite : IBitmapDrawable;

		[Test]
		public function testRegisterType() : void
		{
			IoCHelper.registerType( IBitmapDrawable, Sprite );

			assertTrue( IoCHelper.resolve( IBitmapDrawable ) is Sprite );
		}

		[Test]
		[Ignore]
		public function testRegisterNonImplementingType() : void
		{
			IoCHelper.registerType( IBitmapDrawable, Sound );
		}

		[Test]
		public function testFactory() : void
		{
			IoCHelper.registerType( IBitmapDrawable, Sprite, SingletonFactory );

			assertEquals( IoCHelper.resolve( IBitmapDrawable ), IoCHelper.resolve( IBitmapDrawable ) );
		}

		[Test]
		public function testInjection() : void
		{
			IoCHelper.registerType( IBitmapDrawable, Sprite );
			IoCHelper.injectTo( this );
			assertTrue( sprite != null );
			assertTrue( sprite is Sprite );
		}
	}
}
