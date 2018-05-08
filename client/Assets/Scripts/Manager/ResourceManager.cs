using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public delegate void LoaderCallBack(string path, Object obj, string extends);

class BundleData
{
    public string _path;
    public Object _obj;
    private int _ref = 0;

    public BundleData(string path, Object obj)
    {
        _path = path;
        _obj  = obj;
    }

    public void Use()
    {
        _ref++;
    }

    public void Unuse()
    {
        if (_ref > 0)
            _ref--;
    }

    public bool IsUnused()
    {
        return _ref == 0;
    }
}

class AsyncLoader
{
    public string _path;
    public string _params;
    public ResourceRequest _request;
}

[XLua.LuaCallCSharp]
public class ResourceManager //: MonoBehaviourX
{

    private static ResourceManager _instance = null;
    private Dictionary<string, BundleData> _assetLoaded;
    private string _async_loading_path = "";

    public static ResourceManager Ins
    {
        get {

            if (_instance == null)
                _instance = new ResourceManager();

            return _instance;
        }
    }

    public void Init()
	{
        _assetLoaded = new Dictionary<string, BundleData>();
    }
	
    public Object Load(string path, System.Type t)
    {
        BundleData _data;
        if (false == _assetLoaded.TryGetValue(path, out _data))
        {
            Object obj = Resources.Load(path.Split('.')[0], t);
            if (obj != null)
            {
                _data = new BundleData(path, obj);
                _data.Use();
                _assetLoaded.Add(path, _data);
                return _data._obj;
            }
        }
        else
        {
            _data.Use();
            return _data._obj;
        }
        return null;
    }

    IEnumerator InnerLoad(string path, System.Type type)
    {
        ResourceRequest request = Resources.LoadAsync(path, type);

        request.allowSceneActivation = false;

        while (false == request.isDone)
        {
            yield return null;
        }
        BundleData _data = new BundleData(path, request.asset);
        _data.Use();
        _assetLoaded.Add(path, _data);
        yield return request;
    }

    public void UnloadAll()
    {
        
    }

}

