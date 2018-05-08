using System.Collections;
using System.Collections.Generic;
using XLua;

/// <summary>
/// C# 向LUA发送事件  
/// </summary>
public class CSharpEventToLua 
{
	private static Dictionary<string, bool> EventsMap = new Dictionary<string, bool>();

	/// <summary>
	/// 初始化toLua事件限定列表 
	/// </summary>
	private static void InitToLuaEventMap()
	{
		EventsMap["CSHARP_TO_LUA"] = true;
		EventsMap["LuaCallback0"] = true;
		EventsMap["LuaCallback1"] = true;
		EventsMap["LuaCallback2"] = true;
		EventsMap["LuaCallback3"] = true;
    }
		
	[CSharpCallLua]
	public delegate int FireEventToLua(params object[] list);

	private static FireEventToLua fireEvent;
	public static void FireEvent(string name, object[] arg = null)
	{
		if (fireEvent == null)
		{
			return;
		}

		if (!EventsMap.ContainsKey (name))
		{
			return;
		}

		if (arg == null)
		{
			fireEvent(new object[1] { name });
		}
		else
		{
			object[] args = new object[arg.Length + 1];
			args [0] = name;
			for (int i=0; i<arg.Length; ++i)
			{
				args [i + 1] = arg [i];
			}            
			fireEvent(args);
		}
	}

	/// <summary>
	/// 初始化C# 向LUA发送事件 绑定LUA接受事件函数映射
	/// </summary>
	public static bool Init()
	{
		LuaEnv env = LuaManager.Ins.GetLuaEnv ();
		if (env == null) 
		{
			return false;	
		}

		InitToLuaEventMap ();
		FireEventToLua sendToLuaCall = env.Global.Get<FireEventToLua> ("CSharpCallLuaEvent");
		if (sendToLuaCall == null) 
		{
			return false;
		}

		fireEvent = sendToLuaCall;
		return true;
	}
		
	
	public static void ReleaseLuaFunction()
	{
		fireEvent = null;
	}
}

