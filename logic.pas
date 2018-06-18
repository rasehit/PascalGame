unit logic;

interface
	type 	
		Button = (Right, Left, Zero, Escape);

		nodeptr = ^node;
	
		Player = record
			x, y : integer;
		end;

	 	Enemy = record
			x, y : integer;
		end;

	 	Coin = record
			x, y : integer;
		end;
		
		GameContext = record
			m_limit : double;
			m_spawn, m_score, m_time : integer;
			m_player : Player;
			m_enemies : nodeptr;
			m_term : boolean;
		end;

		node = record
			obj : Enemy;
			next : nodeptr;
		end;

	procedure SetPlayer(var p : Player; x, y: integer);
	procedure MovePlayer(var p : Player; new_x, new_y : integer);
	procedure MovePlayerClick(m_button : Button; var m_player : Player);
	procedure MoveEnemy(p : Enemy);
	procedure EnemyLogic(var p : Player; var pp : nodeptr;
		var spawn : integer);
	procedure CreateEnemy(var pp : nodeptr; x, y : integer);
	procedure DeleteEnemy(var pp : nodeptr);
	procedure MoveEnemies(var pp : nodeptr);
	procedure DisposeList(var pp : nodeptr);
	procedure GetRandomNumbers(var rand1, rand2 : integer);
	procedure TimeControl(var m_game : GameContext; 
		HTIME : integer);
	procedure DrawEnd(score : integer);


	function ReadExtKey() : integer;
	function GetButton() : Button;
	function IsCollide(var p : Player; var pp : nodeptr) : boolean;


implementation
uses crt;


{------------------------------------------------------}
{Initializes player's coordinates                      }
{------------------------------------------------------}
procedure SetPlayer(var p : Player; x, y : integer);
begin
	p.x := x;
	p.y := y;
end;


{------------------------------------------------------}
{Returns number of pressed key, if so                  }
{------------------------------------------------------}

function ReadExtKey() : integer;
var
	c : char;
begin
	c := ReadKey;
	if (c <> #0) then
		ReadExtKey := - ord(c)
	else 
	begin
		c := ReadKey;
		ReadExtKey := ord(c);
	end
end;


{------------------------------------------------------}
{Returns type of pressed button, Zero if not           }
{------------------------------------------------------}
function GetButton() : Button;
var
	p_key : integer;
begin
	if KeyPressed then
	begin
		p_key := ReadExtKey;

		if (p_key = 77) then 
		begin
			GetButton := Right;
			exit;
		end;

		if (p_key = 75) then 
		begin
			GetButton := Left;
			exit;
		end;

		if (p_key = -27) then 
		begin
			GetButton := Escape;
			exit;
		end;
	end
	else 
	begin
		GetButton := Zero
	end;
end;


{------------------------------------------------------}
{Redraws Player() object on the field                  }
{------------------------------------------------------}
procedure MovePlayer(var p : Player; new_x, new_y : integer);
var 
	i, ox, nx : integer;
begin

	ox := 17+10*(p.x-1);
	nx := 17+10*(new_x-1);

	for i := 0 to 7 do 
	begin
		gotoxy(ox, p.y+i);
		writeln('        ');
	end;

	gotoxy(nx, new_y+i);
	writeln('   00   ');gotoxy(nx, new_y+1);
	writeln('  0000  ');gotoxy(nx, new_y+2);
	writeln('  0000  ');gotoxy(nx, new_y+3);
	writeln('00000000');gotoxy(nx, new_y+4);
	writeln('   00   ');gotoxy(nx, new_y+5);
	writeln('   00   ');gotoxy(nx, new_y+6);
	writeln('  0000  ');gotoxy(nx, new_y+7);

	p.x := new_x;
	p.y := new_y;
end;


{------------------------------------------------------}
{Redraws Enemy() object on the field                   }
{------------------------------------------------------}
procedure MoveEnemy(p : Enemy);
var 
	i, ox: integer;
begin
	ox := 17+10*(p.x-1);

	for i := 0 to 7 do 
	begin
		gotoxy(ox, p.y+i);
		if ((p.y+i) > 0) and ((p.y+i) < screenheight) then 
			writeln('        ');
	end;

	for i := 0 to 7 do 
	begin
		gotoxy(ox, p.y+i+1);
		if ((p.y+i+1) > 0) and ((p.y+i+1) < screenheight) then 
			writeln('00000000');
	end;
end;


{------------------------------------------------------}
{Spawns and draws Enemy() objects                      }
{------------------------------------------------------}
procedure EnemyLogic(var p : Player; var pp : nodeptr;
	var spawn : integer);
var 
	rand1, rand2 : integer;
begin
	if (spawn >= 33) then 
	begin
		spawn := 0;
		
		GetRandomNumbers(rand1, rand2);
		CreateEnemy(pp, rand1, -7);
		CreateEnemy(pp, rand2, -8);
		if (rand1 = 1) or (rand1 = 3) then
			CreateEnemy(pp, rand1, -18)
		else 
			CreateEnemy(pp, rand2, -18);

	end;
	MoveEnemies(pp);
	
end;


{-----------------------------------------------------}
{Returns two different random numbers in range [1, 3] }
{-----------------------------------------------------}
procedure GetRandomNumbers(var rand1, rand2 : integer);
begin
	randomize;
	rand1 := random(3)+1;
	rand2 := random(3)+1;
	if(rand1 = rand2) then
	begin
		if (rand1 = 1) then
			rand2 := random(2)+2;
	
			
		if (rand1 = 2) then
		begin
			if (random(2) = 0) then
				rand2 := 1
       			else 	       	
				rand2 := 3;
		end;

		if (rand1 = 3) then 
			rand2 := random(2)+1;
		
	
	end;

end;


{------------------------------------------------------}
{Adds Enemy() object to the list                       }
{------------------------------------------------------}
procedure CreateEnemy(var pp : nodeptr; x, y : integer);
var 
	p : nodeptr;
begin
	if (pp = nil) then 
	begin
		new(pp);
		pp^.obj.x := x;
		pp^.obj.y := y;
		pp^.next := nil;
	end
	else 
	begin
		p := pp;
		while (p^.next <> nil) do
		begin
			p := p^.next;
		end;

		new (p^.next);
		p := p^.next;
		p^.obj.x := x;
		p^.obj.y := y;
		p^.next := nil;
	end;
end;


{------------------------------------------------------}
{Deletes FIRST object from the list                    }
{------------------------------------------------------}
procedure DeleteEnemy(var pp : nodeptr);
var
	p : nodeptr;
begin
	if (pp = nil) then exit;
	p := pp;
	pp := pp^.next;
	dispose(p);
end;


{------------------------------------------------------}
{Redraws all objects in the list                       }
{------------------------------------------------------}
procedure MoveEnemies(var pp : nodeptr);
var
	p : nodeptr;
begin	
	if (pp <> nil) and (pp^.obj.y > screenheight) then
	       DeleteEnemy(pp);

	p := pp;	

	while (p <> nil) do 
	begin
		MoveEnemy(p^.obj);
		p^.obj.y := p^.obj.y + 1;	
		p := p^.next;
	end
	
end;


{------------------------------------------------------}
{Checks if player and an enemy collides                }
{Returns TRUE if so, FALSE if not                      }
{------------------------------------------------------}
function  IsCollide(var p : Player; var pp : nodeptr) : boolean;
var
	l : nodeptr;
	tr : boolean;
begin
	l := pp;
	tr := false;

	while (l <> nil) do
	begin
		if (l^.obj.x = p.x) and (l^.obj.y+8 > p.y) then
		begin
			tr := true;
			break;
		end;

		l := l^.next;
	end;

	IsCollide := tr;
end;


{------------------------------------------------------}
{Disposes list of Enemy() objects                      }
{------------------------------------------------------}
procedure DisposeList(var pp : nodeptr);
var
	p, l : nodeptr;
	
begin
	p := pp;

	while p <> nil do
	begin
		l := p;
		p := p^.next;
		dispose(l);
	end;

end;


{------------------------------------------------------}
{Draws inforamion after game has ended                 }
{------------------------------------------------------}
procedure DrawEnd(score : integer);
var 
	x, y : integer;
begin
	clrscr;

	x := screenwidth div 2 - 15;
	y := screenheight div 2 - 5;

	gotoxy(x, y);
	write(' OOO     O      O  O   OOOOO');gotoxy(x, y+1);
	write('O       O O     O  O   O    ');gotoxy(x, y+2);
	write('O OOO  O   O   O OO O  OOOOO');gotoxy(x, y+3);
	write('O   O  OOOOO   O OO O  O    ');gotoxy(x, y+4);
	write(' OOO  O     O O      O OOOOO');gotoxy(x, y+5);
	write('                            ');gotoxy(x, y+6);
	write('  OOO  O     O OOOOO  OOOO ');gotoxy(x, y+7);
	write(' O   O  O   O  O      O   O');gotoxy(x, y+8);
	write(' O   O  O   O  OOOOO  OOOO ');gotoxy(x, y+9);
	write(' O   O   O O   O      O  O ');gotoxy(x, y+10);
	write('  OOO     O    OOOOO  O   O');gotoxy(x, y+11);
	write('                           ');gotoxy(x, y+12);
	writeln('     Your score is: ', score);

	y := y + 12;

	while y < screenheight-1 do 
       	begin
		writeln();
		y := y + 1;	
	end;	       
	delay(1000);

end;


procedure  MovePlayerClick(m_button : Button; var m_player : Player);
begin
	if (m_button = Right) and (m_player.x < 5) then
	begin
		MovePlayer(m_player, m_player.x+1, m_player.y);
	end;

	if (m_button = Left) and (m_player.x > 1) then 
	begin
		MovePlayer(m_player, m_player.x-1, m_player.y);
	end;

end;


procedure TimeControl(var m_game : GameContext; HTIME : integer);
begin
	m_game.m_time := m_game.m_time + HTIME;
	if (m_game.m_time >= m_game.m_limit) then
	begin
		{Spawning and drawing enemies and checking}
		{collision with the player, increasing score}
		m_game.m_time := 0;
		m_game.m_spawn := m_game.m_spawn + 1;
		m_game.m_score := m_game.m_score + 1;
		if (m_game.m_score > 100) then 
			m_game.m_limit := 15 +  (4000/m_game.m_score);

		EnemyLogic(m_game.m_player, 
			m_game.m_enemies, m_game.m_spawn);
				
	end;

end;



end.
