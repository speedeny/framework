using System.Collections;
using System.Collections.Generic;
/// <summary>
/// unity 内发送事件 
/// </summary>
/// 
public class LuaEventer : Eventer
{
    public override void Fire(string name)
    {
		base.Fire(name);
		CSharpEventToLua.FireEvent (name);
    }

	public override void Fire(string name, object[] args)
	{
		base.Fire(name, args);
		CSharpEventToLua.FireEvent (name, args);
	}

	// 只能被LuaEventToCSharp调用，打破csharp和lua事件监听和发送的循环
	public void Fire2CSharpOnly(string name, object[] args)
	{
		base.Fire (name, args);
	}
}
