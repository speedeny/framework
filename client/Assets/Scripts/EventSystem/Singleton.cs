using System;

/**
 * declare: 
 *     public class ClassName : Singleton<ClassName>
 * usage:
 *     Singleton<ClassName>.Ins.XXX()
 */
public class Singleton<T> where T : new()
{
    private static T instance;

    public static T Ins
    {
        get
        {
            if (Singleton<T>.instance == null)
            {
                Singleton<T>.instance = ((default(T) == null) ? Activator.CreateInstance<T>() : default(T));
            }
            return Singleton<T>.instance;
        }
    }
}
