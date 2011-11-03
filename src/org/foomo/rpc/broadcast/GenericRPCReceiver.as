package org.foomo.rpc.broadcast
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import org.foomo.rpc.broadcast.events.IncomingDataEvent;
	import org.foomo.utils.DebugUtil;
	
	public class GenericRPCReceiver extends EventDispatcher
	{
		private var _receiverClient:RPCReceiverClient;
		
		public function GenericRPCReceiver(receiverClient:RPCReceiverClient)
		{
			super(null);
			this._receiverClient = receiverClient;
			this._receiverClient.addEventListener('incoming', this.handleIncoming);
		}
		
		protected function handleIncoming(event:IncomingDataEvent):void
		{
			throw new Error('well I guess you want to implement me');
		}
	}
}