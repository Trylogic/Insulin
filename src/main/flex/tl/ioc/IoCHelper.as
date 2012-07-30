package tl.ioc
{

	import flash.utils.*;

	import tl.factory.SingletonFactory;

	import tl.ioc.mxml.Associate;
	import tl.ioc.mxml.GroupAssociate;
	import tl.ioc.mxml.IAssociate;
	import tl.utils.describeTypeCached;

	[Inject]
	/**
	 * Basic IoC container.
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
		public static const INJECTION_TAG : String = "Inject";
		private static const aliases : Dictionary = new Dictionary();
		private static const injectsByObject : Dictionary = new Dictionary();
		private static const injectsByClass : Dictionary = new Dictionary();

		{
			if ( describeTypeCached( IoCHelper )..metadata.(@name == INJECTION_TAG).length() == 0 )
			{
				throw new Error( "Please add -keep-as3-metadata+=" + INJECTION_TAG + " to flex compiler arguments!" )
			}
		}

		/**
		 * Return instance for passed iface.
		 *
		 * @see makeInstance
		 *
		 * @param iface        Interface of returned instance
		 * @param instance    Optional instance, passed to <code>getInstanceForInstance</code> function of implementation Class
		 * @return            iface implementator
		 */
		public static function resolve( iface : Class, instance : * = null ) : *
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
		 * Process injections on target
		 *
		 * @param resolvedInstance    target
		 * @param forInstance        optional and for internal use
		 */
		public static function injectTo( resolvedInstance : Object ) : void
		{
			var injects : Vector.<InjectDescription>;
			var injectsCollection : Dictionary = resolvedInstance is Class ? injectsByClass : injectsByObject;

			if ( !(resolvedInstance is Class) )
			{
				const resolvedInstanceConstructor : Class = (resolvedInstance as Object).constructor;
				injectTo( resolvedInstanceConstructor );
			}

			injects = injectsCollection[resolvedInstance];

			if ( injects == null )
			{
				injects = new Vector.<InjectDescription>();
				const instanceDescription : XML = describeTypeCached( resolvedInstance );
				instanceDescription.variable.(valueOf().metadata.(@name == INJECTION_TAG).length()).(
						injects.push( new InjectDescription( @name, getDefinitionByName( @type ) as Class ) )
						);

				instanceDescription.accessor.(@access != "readonly").(valueOf().metadata.(@name == INJECTION_TAG).length()).(
						injects.push( new InjectDescription( String( @name ), getDefinitionByName( String( @type ) ) as Class ) )
						);

				injectsCollection[resolvedInstance] = injects;
			}

			for each( var injectDescription : InjectDescription in injects )
			{
				resolvedInstance[injectDescription.name] = resolve( injectDescription.type, resolvedInstance );
			}

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
