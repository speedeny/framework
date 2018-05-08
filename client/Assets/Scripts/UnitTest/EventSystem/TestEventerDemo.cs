using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestEventerDemo : MonoBehaviourX {

	// Use this for initialization
	void Start () {


		this.scope.Listen ("LUA_TO_CSHARP", delegate(object[] args) {
			UnityEngine.Debug.Log("c# =============== received LUA_TO_CSHARP parapms count " + args.Length.ToString());
		});

		this.scope.Listen ("CSHARP_TEST_EVENT", delegate(object[] args) {
			UnityEngine.Debug.Log("c# =============== received CSHARP_TEST_EVENT parapms count " + args.Length.ToString());
		});



		// 先LUA 发送事件-- 去CSharpEventToLua 里的EventsMap 增加你发送的时间名字 = true 
		EventSystem.Ins.Fire ("CSHARP_TO_LUA", new object[3]{1,2,3});
		EventSystem.Ins.Fire ("CSHARP_TEST_EVENT", new object[3]{1,2,3});
	}
	
	// Update is called once per frame
	void Update () {
		
	}
}
