package org.foomo.rpc.broadcast
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.ObjectEncoding;
	import flash.net.Socket;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import mx.utils.Base64Decoder;
	
	import org.foomo.rpc.broadcast.events.IncomingDataEvent;
	import org.foomo.utils.DebugUtil;

	public class RPCReceiverClient extends EventDispatcher
	{
		
		private var _socket:Socket;
		private var _clientData:Object;
		
		public function RPCReceiverClient(host:String, port:uint, sessionData:Object = null)
		{
			if(!sessionData) {
				sessionData = {};
			}
			this._socket = new Socket;
			
			//trace('bigEndian : ' + (Endian.BIG_ENDIAN == this._socket.endian));
			//this._socket.objectEncoding = ;
			this._clientData = {
				sessionData:sessionData,
				client: {
					type: 'Flash',
					dataFormat : 'AMF0',
					version: Capabilities.version 
				}
			};
			
			
			
			this._socket.addEventListener(ProgressEvent.SOCKET_DATA, this.handleSocketData);
			
			this._socket.addEventListener(
				SecurityErrorEvent.SECURITY_ERROR, 
				function(event:SecurityErrorEvent):void
				{
					trace('me fuckin knew it ' + event.text)
				}
			);
			this._socket.addEventListener(
				IOErrorEvent.IO_ERROR,
				function(event:IOErrorEvent):void {
					trace('wtf IO error' + event.text)
				}
			);
			this._socket.addEventListener(Event.CONNECT, this.handleConnect);
			this._socket.connect(host, port);
		}
		private function handleConnect(event:Event):void
		{
			this._socket.writeMultiByte(JSON.stringify(this._clientData), "iso-8859-1");
		}
		private var _messageLength:uint = 0;
		private function handleSocketData(event:ProgressEvent):void
		{
			try {
				while(this._socket.bytesAvailable >= 4) {
					if(this._messageLength == 0) {
						this._messageLength = this._socket.readUnsignedInt();
						//trace('messageLength: ' + this._messageLength);
					} 
					if(this._messageLength > 0 && this._socket.bytesAvailable >= this._messageLength) {
						var objByteArray:ByteArray = new ByteArray;
						objByteArray.objectEncoding = ObjectEncoding.AMF0;
						switch('binary') {
							case 'binary':
								// trace('socket before obj read ' + this._socket.bytesAvailable);
								this._socket.readBytes(objByteArray, 0, this._messageLength);
								break;
							case 'base64':
								var decoder:Base64Decoder = new Base64Decoder;
								var base64ByteArray:ByteArray = new ByteArray;
								this._socket.readBytes(base64ByteArray, 0, this._messageLength);
								var base64:String = base64ByteArray.toString();
								decoder.decode(base64);
								objByteArray = decoder.toByteArray();
								objByteArray.objectEncoding = ObjectEncoding.AMF0;
								break;
						}
						// trace('socket after obj read ' + this._socket.bytesAvailable);
						try {
							var obj:Object = objByteArray.readObject();
							// DebugUtil.dump(obj);
							//var obj:Object = this._socket.readObject();
							this.dispatchEvent(new IncomingDataEvent(IncomingDataEvent.INCOMING, obj.event, obj.data));
							// trace('trace so there we are : ' + obj);
						} catch(parseError:Error) {
							trace('messageLength: ' + this._messageLength + ' objByteArray.length: ' + objByteArray.length);
							trace('failed to parse ' + parseError.message);
						}
						this._messageLength = 0;
					} else {
						// trace('waiting for message to arrive : ' + this._socket.bytesAvailable + ' / ' + this._messageLength);
					}
					if(this._messageLength > this._socket.bytesAvailable) {
						return;
					}
				}
			} catch(e:Error) {
				trace('WTF :: ' + e.message);
			}
		}
	}
}