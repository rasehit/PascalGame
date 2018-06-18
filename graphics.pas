unit graphics;


interface

	type
		Vector = record
			x, y, z: double;
		end;


		Sphere = record
			r : double;
			center : Vector;
			color : integer;
		end;


		TType = record
			t1, t2 : double;
		end;

		sp_ptr = ^sp_node;
		sp_node = record
			value : Sphere;
			next : sp_ptr;
		end;

		TCanvas = array[1..79, 1..31] of integer;




	procedure SetPixel(x, y, color: integer);
	procedure PutPixel(x, y, color: integer);
	function CanvasToViewport(x, y, d: integer) : Vector;
	function Dot (a, b: Vector) : double;
	function TraceRay(o, d: Vector; spheres:
       	sp_ptr; min, max: double) : integer;


implementation
uses crt;


procedure SetPixel(x, y, color: integer);
begin
	if (x > 0) and (x < screenwidth) 
		and (y > 0) and (y < screenheight) 
		and (color < 16) then
	begin
		if (color >= 0) then
		begin
			TextColor(color);
			gotoxy(x, y);
			write('o');
		end
		else 
		begin
			gotoxy(x, y);
			write(' ');
		end;
	end;
end;


procedure PutPixel(x, y, color: integer);
var 
	nx, ny : integer;
begin
	nx := (screenwidth div 2) + x;
	ny := (screenheight div 2) - y;
	SetPixel(nx, ny, color);
end;


function CanvasToViewport(x, y, d: integer) : Vector;
var 
	vec : vector;
begin
	vec.x := double(x)/double(screenwidth);
	vec.y := double(y)/double(screenheight);
	vec.z := double(d);

	CanvasToViewport := vec;
	
end;


function Dot (a, b: Vector) : double;
begin
	Dot := a.x*b.x + a.y*b.y + a.z*b.z;
end;


function VectorExtr(a, b: Vector) : Vector;
var 
	temp : Vector;
begin
	temp.x := a.x - b.x;
	temp.y := a.y - b.y;
	temp.z := a.z - b.z;

	VectorExtr := temp;
end;





function IntersectRaySphere(o, d: Vector; sp : sp_ptr) : TType;
var 
	r, k1, k2, k3, dis : double;
	c, oc : Vector;
	T : TType;
begin
	c := sp^.value.center;
	r := sp^.value.r;
	oc := VectorExtr(o, c);

	k1 := Dot(d, d);
	k2 := 2*Dot(oc, d);
	k3 := Dot(oc, oc) - r*r;

	dis := k2*k2 - 4*k1*k3;
	if (dis < 0) then 
	begin
		T.t1 := 99999999;
		T.t2 := 99999999;
		IntersectRaySphere := T;
		exit;
	end;	


	T.t1 := (-k2 + sqrt(dis))/(2*k1);
	T.t2 := (-k2 - sqrt(dis))/(2*k1);

	IntersectRaySphere := T;

end;




function TraceRay(o, d: Vector; spheres:
       	sp_ptr; min, max: double) : integer;
var 
	closest_t : double; 
	closest_sphere : sp_ptr;
	temp : sp_ptr;
	TT : TType;
begin
	closest_t := 9999999;
	closest_sphere := nil;

	temp := spheres;

	while (temp <> nil) do
	begin
		TT := IntersectRaySphere(o, d, temp);

		if (TT.t1 > min) and (TT.t1 < max) 
			and (TT.t1 < closest_t) then
		begin
			closest_t := TT.t1;
			closest_sphere := temp;
		end;

		if (TT.t2 > min) and (TT.t2 < max) 
			and (TT.t2 < closest_t) then
		begin
			closest_t := TT.t2;
			closest_sphere := temp;
		end;

		temp := temp^.next;
	end;

	if (closest_sphere = nil) then
		TraceRay := -1
	else
		TraceRay := closest_sphere^.value.color;

	
end;








end.
