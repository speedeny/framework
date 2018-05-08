using System.Collections;
using System.Collections.Generic;
using XLua;

public static class LuaEventToCSharp 
{
	private static void Fire(string name, object [] args)
	{
		LuaEventer eventer = EventSystem.Ins.eventer as LuaEventer;
		eventer.Fire2CSharpOnly (name, args);
	}

	//  ---------------- 以下接口提供给Lua调用 ----------------------
	[LuaCallCSharp]
	public static void _Fire(string name)
	{
		object[] args = new object[0] {};
		Fire(name, args);
	}

	[LuaCallCSharp]
	public static void _Fire(string name, object arg1)
	{
		object[] args = new object[1] { arg1 };
		Fire(name, args);
	}

	[LuaCallCSharp]
	public static void _Fire(string name, object arg1, object arg2)
	{
		object[] args = new object[2] { arg1, arg2 };
		Fire(name, args);
	}

	[LuaCallCSharp]
	public static void _Fire(string name, object arg1, object arg2, object arg3)
	{
		object[] args = new object[3] { arg1, arg2, arg3 };
		Fire(name, args);
	}

	[LuaCallCSharp]
	public static void _Fire(string name, object arg1, object arg2, object arg3, object arg4) 
	{
		object[] args = new object[4] { arg1, arg2, arg3, arg4 };
		Fire(name, args);
	}

	[LuaCallCSharp]
	public static void _Fire(string name, object arg1, object arg2, object arg3, object arg4, object arg5) 
	{
		object[] args = new object[5] { arg1, arg2, arg3, arg4, arg5 };
		Fire(name, args);
	}

	[LuaCallCSharp]
	public static void _Fire(string name, object arg1, object arg2, object arg3, object arg4, object arg5, object arg6) 
	{
		object[] args = new object[6] { arg1, arg2, arg3, arg4, arg5, arg6 };
		Fire(name, args);
	}
}
