program setup;

uses crt, logic;

const HTIME = 10; {Speed of loop}

var
	m_y : integer;
	m_button : Button;
	m_game : GameContext;
begin
	{----------------- Initializing Variables ---------------------}
	m_y := screenheight-9; 	{y player's coordinate}
	m_button := Zero;	{main variable of Button()}
	
	m_game.m_limit := 100;		{defines speed of game}
	m_game.m_time := 0;		{time variable}
	m_game.m_spawn := 0;		{speed of enemy spawn}
	m_game.m_enemies := nil;	{list of Enemies()}
	m_game.m_term := false;	{flag of game state (in prgress/ended)}
	m_game.m_score := 0;		{player's score}

	{-------------------- Pregame Settings ------------------------}
	clrscr;
	SetPlayer(m_game.m_player, 2, m_y);
	MovePlayer(m_game.m_player, 2, m_y);
	CreateEnemy(m_game.m_enemies, 1, -7);


	{----------------------- Game Loop ----------------------------}
	{Operates until game ends or escape button is pressed          }
	while m_button <> Escape  do
	begin
		{Player's movement control by Left and Right buttons}
		m_button := GetButton();
		MovePlayerClick(m_button, m_game.m_player);

		{Setting speed of loop and working with Enemy() objects}
		delay(HTIME); 
		TimeControl(m_game, HTIME);

		{Displaying current score}
		gotoxy(1, 1);	
		write('Score: ', m_game.m_score);

		{Terminating loop}
		if (m_game.m_term = true) then 	
			break;
	end;

	{Terminating game and deleting dynamic memory}
	DisposeList(m_game.m_enemies);
	DrawEnd(m_game.m_score);
	
end.


