package tl.ioc
{

	public class InjectDescription
	{
		public var name : String;
		public var type : Class;

		public function InjectDescription( name : String, type : Class )
		{
			this.name = name;
			this.type = type;
		}
	}
}
