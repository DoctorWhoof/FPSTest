Namespace clock

#Import "<std>"

Using std.fiber

Function Delay( time:Float, func:Void() )
    New Fiber( Lambda()
        Fiber.Sleep( time )
        func()
    End )
End