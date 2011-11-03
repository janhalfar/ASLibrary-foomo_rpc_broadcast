package org.foomo.rpc.broadcast.events
{
	import flash.events.Event;
	
	public class IncomingDataEvent extends Event
	{
		public static const INCOMING:String = 'incoming';
		public var name:String;
		public var data:*;
		public function IncomingDataEvent(type:String, name:String, data:*)
		{
			super(type);
			this.name = name;
			this.data = data;
		}
	}
}