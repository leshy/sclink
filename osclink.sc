// http://doc.sccode.org/Classes/OSCdef.html

thisProcess.openUDPPort(4000);
thisProcess.openPorts;

OSCFunc.trace(false);
OSCdef.newMatching(\reply, {|msg| msg.postln}, '/reply'); // path matching

~query = {
	arg server, f ... args;
	var queryid = SystemClock.beats.as32Bits;
	
	OSCdef(
		"reply." ++ queryid,
		{
			|msg, time, addr, recvPort|
			msg = msg[1..];
			msg.postln},
		'/reply/' ++ queryid)
	.oneShot;
	
	server.sendMsg("/query/" ++ f, queryid, *args);
	nil
}

~query.(NetAddr.new("127.0.0.1", 4001), "test", 1, "bla")

