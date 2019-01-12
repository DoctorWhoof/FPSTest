Namespace m2extensions

#Import "<std>"
#Import "<mojo>"
#Import "<mojo3d>"

#Import "../math/Math"

Using std..
Using mojo..
Using mojo3d..


Function LineExtrude:Mesh( points:Vertex2f[], length:Float, closedCurve:Bool = False, flip:Bool = False )
	Local front:= New Stack<Vertex3f>
	Local back:= New Stack<Vertex3f>
	Local indices := New Stack<UInt>
	Local vertices := New Stack<Vertex3f>
	
'	Local i := 0
	Local totalVerts := points.Length
	Local sides:= totalVerts
	
	If Not closedCurve sides -= 1
	If totalVerts = 2 Then sides = 1		'Prevents two overlapping planes if line only has two vertices
	
	Local n := 0.0
	For Local v := Eachin points
		Local u := n/ Float(sides)
		front.Push( New Vertex3f(v.position.X, v.position.Y, -length/2, u, 0.0) )
		back.Push( New Vertex3f(v.position.X, v.position.Y, +length/2, u, 1.0) )
		n += 1.0
	Next
	
	For Local i0 := 0 Until sides
		Local i1 := i0 + 1
		If i1 > totalVerts - 1 Then i1 = 0
		
		indices.Push( UInt(i0) )
		indices.Push( UInt(i0 + totalVerts) )
		indices.Push( UInt(i1) )
		indices.Push( UInt(i0 + totalVerts) )
		indices.Push( UInt(i1 + totalVerts) )
		indices.Push( UInt(i1) )
	Next
	
	For Local v := Eachin front
		vertices.Push( v )
	Next
	
	For Local v := Eachin back
		vertices.Push( v )
	Next
	
	Local mesh := New Mesh( vertices.ToArray(), indices.ToArray() )
	mesh.UpdateTangents()
	mesh.UpdateNormals()
	If flip Then mesh.FlipTriangles()
	mesh.Compact()
	Return mesh
End


'Function LineExtrude:Mesh( points:Vertex2f[], segs:Stack<UInt[]>, length:Float, closedCurves:Bool = False, flip:Bool = False )
'	For Local s := Eachin segs
'		
'	Next
'End


Function BoxEdge:Vertex2f[]( width:Float, height:Float, angle:Float, handle:Vec2f = New Vec2f(0.5) )
	Local vertices := New Vertex2f[]( New Vertex2f(0,1), New Vertex2f(1,1) )
	Return TransformLine( vertices, -handle.X, -handle.Y, angle, width, height )
End



Function BoxCorner:Vertex2f[]( width:Float, height:Float , angle:Float, roundness:Float, steps:Int, handle:Vec2f = New Vec2f(0.5) )
	Local verts := New Stack<Vertex2f>
	Local stepsize:Float
	
	If steps > 0
		stepsize = DegToRad(90.0/steps)
	Else
		stepsize = DegToRad(90.0)
	End
		
	If roundness < 1.0
		verts.Push( New Vertex2f( Sin(0), Cos(0) ) )
		If roundness > 0.0
			Local miniCorner := BoxCorner( roundness, roundness, 0, 1.0, steps, New Vec2f )
			For Local v := Eachin miniCorner
				Local offset := 1.0-roundness
				verts.Push( New Vertex2f( v.position.X + offset, v.position.Y + offset ) )
			Next
		Else
			verts.Push( New Vertex2f( 1, 1 ) )
		End
		verts.Push( New Vertex2f( Sin(Pi/2.0), Cos(Pi/2.0) ) )
	Else
		Local a:Double = 0.0
		Repeat
			Local x:= Sin(a)
			Local y:= Cos(a)
			verts.Push( New Vertex2f(x,y) )
			a += stepsize
		Until a > (Pi/2.0) + 0.001
	End
	
	Return TransformLine( verts.ToArray(), -handle.X, -handle.Y, angle, width, height )
End


Function TransformLine:Vertex2f[]( points:Vertex2f[], offsetX:Float, offsetY:Float, angle:Float=0.0, scaleX:Float=1.0, scaleY:Float=1.0 )
	Local angleRad := DegToRad(angle)
	For Local n:= 0 Until points.Length
		Local v := points[n]
		Local x := v.position.X + offsetX
		Local y := v.position.Y + offsetY
		Local newX := ( x * Cos(angleRad) ) - ( y * Sin(angleRad) )
		Local newY := ( y * Cos(angleRad) ) + ( x * Sin(angleRad) )
		newX = ( newX * scaleX )
		newY = ( newY * scaleY )
		points[n] = New Vertex2f( newX, newY )
	Next
	Return points
End
