using System;
using UnityEngine;

public class MonoBehaviourX: MonoBehaviour
{
    protected EventScope scope = null;
    
    protected MonoBehaviourX()
    {
		scope = Eventer.CreateScope();
    }
    
    protected void OnDestroy()
    {
        scope.Destroy();
        scope = null;
    }
}

