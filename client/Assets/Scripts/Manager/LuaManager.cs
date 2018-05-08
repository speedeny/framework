
using System.Collections;
using System.Collections.Generic;
using System;
using XLua;
using UnityEngine;
using System.IO;

public class LuaManager: Singleton<LuaManager>
{
	// 绑定C# 向LUA发送事件的映射
	[CSharpCallLua]
	public delegate void DelegateLuaTimeUpdate(float f);

	// 绑定更新时间映射 
	private DelegateLuaTimeUpdate luaUpdate;

	LuaEnv luaenv = null;

	/// <summary>
	/// 启动LUA
	/// </summary>
	public void Init()
	{

		EventSystem.Ins.Init (new LuaEventer ());

		luaenv = new LuaEnv();
		luaenv.AddLoader(LoadFile);
		luaenv.DoString ("require 'Boot'");
		StartLua ();
	}	
		
	/// <summary>
	/// 加载文件
	/// </summary>
	/// <returns>The boot.</returns>
	/// <param name="filepath">Filepath.</param>
	private byte[] LoadFile (ref string filepath)
	{
		filepath = Application.dataPath.Replace("Assets", "") + "Data/LuaScript/" + filepath.Replace('.', '/') + ".lua";
		if (File.Exists(filepath))
		{
			return File.ReadAllBytes(filepath);
		}
		else
		{
			return null;
		}
	}

	public LuaEnv GetLuaEnv()
	{
		return luaenv;
	}

	public void Update(float dt)
	{
		if (luaenv != null) 
		{
			luaenv.Tick ();
		}

		if (luaUpdate != null) 
		{
			luaUpdate (dt);
		}
	}
		
	/// <summary>
	/// 加载完成
	/// </summary>
	public void StartLua()
	{
		// 绑定更新LUA时间戳
		luaUpdate = luaenv.Global.Get<DelegateLuaTimeUpdate>("LuaUpdate");

		if (luaUpdate == null) 
		{
			Debug.LogError ("Lua Bind UpdateLua Fail");
			return;
		}

		if (!CSharpEventToLua.Init ()) 
		{
			Debug.LogError ("CSharpEventToLua.Init Fail");
			return;
		}
	}
		
	public void Release()
	{
		CSharpEventToLua.ReleaseLuaFunction ();
		luaUpdate = null;
		luaenv.Dispose ();
	}
}
