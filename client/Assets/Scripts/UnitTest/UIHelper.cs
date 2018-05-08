using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using XLua;

[LuaCallCSharp]
public class UIHelper
{
    public static void SetActive(GameObject go, bool active)
    {
        if (go != null)
        {
            NGUITools.SetActive(go, active);
        }
    }

    public static bool GetActive(GameObject go)
    {
        if (go != null)
        {
            return NGUITools.GetActive(go);
        }
        return false;
    }

    public static void ChangeUIPanelDepth(GameObject parent, int depth)
    {
        var panel = parent.GetComponent<UIPanel>();

        if (panel != null)
            panel.depth = depth;

        for (int i = 0; i < parent.transform.childCount; ++i)
        {
            ChangeUIPanelDepth(parent.transform.GetChild(i).gameObject, depth + 1);
        }
    }


    public static void BindClickEvent(GameObject go, double lua)
    {
        if (go != null)
        {
            UIEventListener.Get(go).onClick = delegate (GameObject o)
            {
                EventSystem.Ins.Fire("LuaCallback0", new object[] { lua});
            };
        }
        else
        {
            Debug.LogWarning("UIHelper::BindClickEvent go=nil!");
        }
    }

    public static void BindDragEvent(GameObject go, double lua)
    {
        if (go != null)
        {
            UIEventListener.Get(go).onDrag = delegate (GameObject o, Vector2 delta)
            {
                EventSystem.Ins.Fire("LuaCallback2", new object[] { lua, delta.x, delta.y });
            };
        }
        else
        {
            Debug.LogWarning("UIHelper::BindDragEvent go=nil!");
        }
    }   

    public static void BindPressEvent(GameObject go, double lua)
    {
        if (go != null)
        {
            UIEventListener.Get(go).onPress = delegate (GameObject o, bool state)
            {
                float x = 0f;
                float y = 0f;

                if (Input.touchCount <= 0)
                {
                    x = Input.mousePosition.x;
                    y = Input.mousePosition.y;
                }
                else
                {
                    Touch t = Input.GetTouch(0);
                    if (Input.touchCount > 1)
                    {
                        int lastId = -1;
                        for (int i = 0; i < Input.touchCount; i++)
                        {
                            Touch temp = Input.GetTouch(i);
                            if (temp.fingerId > lastId)
                            {
                                lastId = temp.fingerId;
                                t = temp;
                            }
                        }
                    }

                    x = t.position.x;
                    y = t.position.y;
                }
                EventSystem.Ins.Fire("LuaCallback3", new object[] { lua, state, x, y });                
            };
        }
        else
        {
            Debug.LogWarning("UIHelper::BindPressEvent go=nil!");
        }
    }

	public static GameObject AddChildPrefab(GameObject parent, string path)
	{
		UnityEngine.Object obj = ResourceManager.Ins.Load (path, typeof(GameObject));
		if (obj != null) {
			
			GameObject child = GameObject.Instantiate (obj) as GameObject;
			child.transform.parent = parent.transform;
			child.transform.localPosition = Vector3.zero;
			child.transform.localScale = Vector3.one;
			return child;
		}
		return null;
	}

    public static GameObject FindChildByName(GameObject parent, string str)
    {
        if (null == parent)
        {
            Debug.LogError("FindChildByName NULL Parent: " + str);
            return null;
        }
        return _RecursionFindChild(parent, str);
    }

	private static GameObject _RecursionFindChild(GameObject obj, string name)
	{
		Transform childTrans = obj.transform.Find(name);
		if (null != childTrans)
		{
			return childTrans.gameObject;
		}
		else
		{
			for (int i = 0; i < obj.transform.childCount; ++i)
			{
				GameObject child = _RecursionFindChild(
					obj.transform.GetChild(i).gameObject, name);

				if (child != null)
				{
					return child;
				}
			}
		}

		return null;
	}
}
