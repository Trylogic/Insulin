package tl.factory
{

	import flash.utils.Dictionary;

	public class SingletonFactory
	{
		private static const cache : Dictionary = new Dictionary();

		public static function makeInstance( type : Class, forInstance : Object = null ) : Object
		{
			if ( cache[type] == null )
			{
				cache[type] = new type();
			}

			return cache[type];
		}

		public static function registerImplementation( type : Class, implementation : Object ) : void
		{
			if ( cache[type] != null )
			{
				throw new Error( "Singleton for type " + type + " is already registered!" );
			}

			if ( !(implementation is type) )
			{
				throw new ArgumentError( "Implementation MUST implement type " + type );
			}

			cache[type] = implementation;
		}
	}
}
