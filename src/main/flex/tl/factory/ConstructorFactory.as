package tl.factory
{

	public class ConstructorFactory
	{
		public static function makeInstance( type : Class, forInstance : Object = null ) : Object
		{
			return new (type)( forInstance );
		}
	}
}
