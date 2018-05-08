//using System.Collections;
//using System.Collections.Generic;
using XLua;
using UnityEngine;

public class GameManager : MonoBehaviour {

	// Use this for initialization
	void Awake()
	{
		ResourceManager.Ins.Init ();
		LuaManager.Ins.Init ();
	}

	// Update is called once per frame
	void Update()
	{
		LuaManager.Ins.Update (Time.deltaTime);
	}

	void OnDestroy()
	{
		LuaManager.Ins.Release ();
        ResourceManager.Ins.UnloadAll();

    }


}
