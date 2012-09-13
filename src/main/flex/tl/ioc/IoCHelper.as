package tl.ioc
{

	import flash.utils.*;

	import tl.factory.SingletonFactory;
	import tl.ioc.mxml.Associate;
	import tl.ioc.mxml.GroupAssociate;
	import tl.ioc.mxml.IAssociate;

	/**
	 * Basic IoC.
	 *
	 * @example
	 * <listing version="3.0">
	 *     public interface ILogger
	 *     {
	 *             function log(...args) : void;
	 *     }</listing>
	 *
	 * <listing version="3.0">
	 *     public class MyLogger implements ILogger
	 *     {
	 *             public fuction log(...args) : void
	 *             {
	 *                 trace(args);
	 *             }
	 *     }</listing>
	 *
	 * <listing version="3.0">
	 *     public class MyInjectedClass
	 *     {
	 *            [Inject]
	 *            public var logger : ILogger;
	 *
	 *            public function MyInjectedClass()
	 *            {
	 *                IoCHelper.injectTo(this);
	 *            }
	 *
	 *            public function doSomething() : void
	 *            {
	 *                logger.log("something");
	 *            }
	 *        }</listing>
	 *
	 * <listing version="3.0">
	 *     public class MyClass
	 *     {
	 *            public fuction MyClass()
	 *            {
	 *                IoCHelper.registerType(ILogger, MyLogger, SingletonFactory);
	 *                var injectedObject : MyInjectedClass = new MyInjectedClass();
	 *                injectedObject.doSomething(); // Will trace "something"
	 *            }
	 *        }</listing>
	 */
	public class IoCHelper
	{
		private static const aliases : Dictionary = new Dictionary();

		/**
		 * Return instance for passed iface.
		 *
		 * @see makeInstance
		 *
		 * @param iface        Interface of returned instance
		 * @param instance    Optional instance, passed to <code>getInstanceForInstance</code> function of implementation Class
		 * @return            iface implementator
		 */
		public static function resolve( iface : Class, instance : * ) : *
		{
			var assoc : Associate = aliases[iface];
			var resolvedInstance : *;

			if ( assoc == null )
			{
				throw new Error( "Nothing is registered to " + iface );
			}

			try
			{
				resolvedInstance = assoc.withClass.ioc_internal::getInstanceForInstance( instance );
			}
			catch ( e : ReferenceError )
			{
				try
				{
					resolvedInstance = assoc.withClass.ioc_internal::getInstance();
				}
				catch ( e : ReferenceError )
				{
					if ( assoc.factory != null )
					{
						resolvedInstance = Class( assoc.factory ).makeInstance( assoc.withClass, instance );
					}
					else
					{
						resolvedInstance = new assoc.withClass();
					}
				}
			}

			return resolvedInstance;
		}

		/**
		 * Associate iface with targetClass
		 *
		 * @param iface
		 * @param targetClass
		 * @param factory
		 */
		public static function registerType( iface : Class, targetClass : Class, factory : Class = null ) : void
		{
			registerAssociate( new Associate( iface, targetClass, factory ) );
		}

		/**
		 * Associate iface with it's singleton implementation targetClass
		 *
		 * @param iface
		 * @param implementation
		 */
		public static function registerSingleton( iface : Class, implementation : Object ) : void
		{
			registerAssociate( new Associate( iface, iface, SingletonFactory ) );
			SingletonFactory.registerImplementation( iface, implementation );
		}

		/**
		 * Process IAssociate object
		 *
		 * @param assoc
		 */
		public static function registerAssociate( assoc : IAssociate ) : void
		{
			if ( assoc is GroupAssociate )
			{
				for each( var inAssoc : IAssociate in GroupAssociate( assoc ).data )
				{
					registerAssociate( inAssoc );
				}
			}
			else if ( assoc is Associate )
			{
				if ( Associate( assoc ).iface == null )
				{
					throw new Error( "Association's iface property cann't be null!" );
				}

				aliases[Associate( assoc ).iface] = assoc;
			}
		}
	}
}
