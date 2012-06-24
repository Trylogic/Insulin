package tl.factory
{
	import flash.utils.Dictionary;

	public class SingletonFactory
	{
		private static const cache : Dictionary = new Dictionary();

		public static function makeInstance(type : Class, forInstance : Object = null) : Object
		{
			if(cache[type] == null)
			{
				cache[type] = new type();
			}
			
			return cache[type];
		}
	}
}