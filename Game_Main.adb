--TODO: Resizing fails terribly
with SDL.Keysym; use SDL.Keysym;
with SDL.keyboard; use SDL.Keyboard;
with SDL.Types;                                 use SDL.Types;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Game_Model_Operations; use Game_Model_Operations;
with Game_Framework;        use Game_Framework;
with GL_H;                  use GL_H;
with GLU_H;                 use GLU_H;
with AdaGL;                 use AdaGL;
with Ada.Text_IO;           use Ada.Text_IO;
with Interfaces.C;          use Interfaces.C;
procedure Game_Main is
	pragma Link_With("-lOPENGL32 -lSDL -lSDL_MIXER -lGLU");
	---------------------------------------------------------------------
	-- OpenGL global variables for simplified subprogram communication --
	---------------------------------------------------------------------
	screen_width         : Integer := 640;
	screen_height        : Integer := 480;
	rotation_x           : Float := 0.0;
	rotation_x_increment : Float := 0.0001;
	rotation_y           : Float :=0.0;
	rotation_y_increment : Float := 0.0001;
	rotation_z           : Float :=0.0;
	rotation_z_increment : Float :=0.0001;
	filling              : Integer := 1;
	light_ambient        : Four_GLfloat_Vector := ( 0.1, 0.1, 0.1, 0.1 );
	light_diffuse        : Four_GLfloat_Vector := ( 1.0, 1.0, 1.0, 0.0 );
	light_specular       : Four_GLfloat_Vector := ( 1.0, 1.0, 1.0, 0.0 );
	light_position       : Four_GLfloat_Vector := ( 100.0, 0.0, -10.0, 1.0 );
	mat_ambient          : Four_GLfloat_Vector := ( 0.2, 0.2, 0.2, 0.0 );
	mat_diffuse          : Four_GLfloat_Vector := ( 0.2, 0.2, 0.2, 0.0 );
	mat_specular         : Four_GLfloat_Vector := ( 1.0, 1.0, 1.0, 0.0 );
	mat_shininess        : GLfloat := ( 1.0 );
	Model : Record_Model;
	Texture : Boolean := TRUE;
	----------------------
	-- Initialize_Scene --
	----------------------
	procedure Initialize_Scene
		is
		begin
			Model := Load_3DS_Model ("fighter1.3ds","Test.bmp");
			null;
		end Initialize_Scene;
	------------------
	-- Update_Scene --
	------------------
	procedure Update_Scene
		is
		Polygon_Index : Integer;
		begin
			glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
			glMatrixMode(GL_MODELVIEW);
			glLoadIdentity;
			glTranslatef(0.0,0.0,-20.0);
			if rotation_x > 359.0 then
				rotation_x := 0.0001;
			elsif rotation_y > 359.0 then
				rotation_y := 0.0001;
			elsif rotation_z > 359.0 then
				rotation_z := 0.0001;
			end if;
			glRotatef(rotation_x,1.0,0.0,0.0);
			glRotatef(rotation_y,0.0,1.0,0.0);
			glRotatef(rotation_z,0.0,0.0,1.0);
			if Model.Texture_Id /= -1 and Texture then
				glBindTexture(GL_TEXTURE_2D, Unsigned(Model.Texture_Id));
				glEnable(GL_TEXTURE_2D);
			else
				glDisable(GL_TEXTURE_2D);
			end if;
			glBegin(GL_TRIANGLES);
				for I in 1..Integer(Model.Polygons) loop
					for J in 1..3 loop
						Polygon_Index := Integer(Model.Polygon(I,J) + 1);
						glNormal3f
						(
							Model.Normal(Polygon_Index).X,
							Model.Normal(Polygon_Index).Y,
							Model.Normal(Polygon_Index).Z
						);
						glTexCoord2f
						(
							Model.Map_Coordinate(Polygon_Index).U,
							Model.Map_Coordinate(Polygon_Index).V
						);
						glVertex3f
						(
							Model.Vertex(Polygon_Index).X,
							Model.Vertex(Polygon_Index).Y,
							Model.Vertex(Polygon_Index).Z
						);
					end loop;
				end loop;
			glEnd;
			glFlush;
			GL_SwapBuffers;									
		end Update_Scene;
	-------------------------
	-- Initialize_Viewport --
	-------------------------
	procedure Initialize_Viewport
		(Width  : in     Integer;
		 Height : in     Integer)
		is
		h : GLdouble := GLdouble(height) / GLdouble(width);
		begin
			glClearColor(0.0, 0.0, 0.0, 0.0);
			glViewport(0,0,width,Height);  
			glMatrixMode(GL_PROJECTION);
			glLoadIdentity;
			gluPerspective(Gl_H.GLdouble(45.0),Gl_H.GLdouble(width/Height),Gl_H.GLdouble(5.0),Gl_H.GLdouble(10000.0));
			glLightfv (GL_LIGHT1, GL_AMBIENT, light_ambient);
			glLightfv (GL_LIGHT1, GL_DIFFUSE, light_diffuse);
			glLightfv (GL_LIGHT1, GL_DIFFUSE, light_specular);
			glLightfv (GL_LIGHT1, GL_POSITION, light_position);    
			glEnable (GL_LIGHTING);
			glEnable (GL_LIGHT1);
			glMaterialfv (GL_FRONT, GL_AMBIENT, mat_ambient);
			glMaterialfv (GL_FRONT, GL_DIFFUSE, mat_diffuse);
			glMaterialfv (GL_FRONT, GL_DIFFUSE, mat_specular);
			glMaterialfv (GL_FRONT, GL_POSITION, mat_shininess);    
			glShadeModel(GL_SMOOTH);
			glHint (GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
			glEnable(GL_TEXTURE_2D);
			glPolygonMode (GL_FRONT_AND_BACK, GL_FILL);
			glEnable(GL_CULL_FACE);
			glEnable(GL_DEPTH_TEST);
		end Initialize_Viewport;
	------------------
	-- Update_Video --
	------------------
	procedure Update_Video
		(Video  : in out Video_Initialization_Handle;
		 Height : in     Short_Integer;
		 Width  : in     Short_Integer)
		is
		begin
			Video.Width   := Width;
			Video.Height  := Height;
			Quit_Framework;
			Initialize_Video
			(
				Video => Video
			);
			Initialize_Scene;
			Initialize_Viewport
			(
				Width  => Integer(Video.Width),
				Height => Integer(Video.Height)
			);
			Update_Scene;
		end Update_Video;
	-----------------------
	-- Manage_Keypressed --
	-----------------------
	procedure Handle_Keypressed
		(Loop_Control : in out Boolean)
		is
		Pressed_Key : Uint8_ptr := GetKeyState(null);
		begin
			if Is_Key_Pressed(Pressed_Key,K_ESCAPE) then
				Loop_Control := FALSE;
			end if;
			if Is_Key_Pressed(Pressed_Key,K_UP) then 
				rotation_x := rotation_x + rotation_x_increment;
			end if;
			if Is_Key_Pressed(Pressed_Key,K_LEFT) then 
				rotation_y := rotation_y + rotation_y_increment;
			end if;
			if Is_Key_Pressed(Pressed_Key,K_DOWN) then
				rotation_x := rotation_x - rotation_x_increment;
			end if;
			if Is_Key_Pressed(Pressed_Key,K_RIGHT) then 
				rotation_y := rotation_y - rotation_y_increment;
			end if;
			if Is_Key_Pressed(Pressed_Key,K_KP_PERIOD) then 
				rotation_z := rotation_z + rotation_z_increment;
			end if;
			if Is_Key_Pressed(Pressed_Key,K_KP0) then
				rotation_z := rotation_z - rotation_z_increment;
			end if;
			if Is_Key_Pressed(Pressed_Key,K_SPACE) then
				if Texture = FALSE then
					Texture := TRUE;
				else
					Texture := FALSE;
				end if;
			end if;
		end Handle_Keypressed;
	-------------------
	-- Manage_Events --
	-------------------	
	procedure Manage_Events
		(Video        : in out Video_Initialization_Handle;
		 Loop_Control : in out Boolean)
		is
		Current_Event : Event;
		Result        : Integer;
		begin
			PollEventVP
			(
				result    => int(Result),
				the_event => Current_Event
			);
			case Current_Event.The_Type is
				when Quit =>
					Loop_Control := FALSE;
				when Videoresize =>
					Put_Line(Interfaces.C.int'Image(Current_Event.Resize.H));
					Put_Line(Interfaces.C.int'Image(Current_Event.Resize.W));
					Update_Video
					(
						Video  => Video,
						Height => Short_Integer(Current_Event.Resize.H),
						Width  => Short_Integer(Current_Event.Resize.W)
					);
				when others =>
					Null;
			end case;
		end Manage_Events;
	---------
	-- Run --
	---------
   	procedure Run
		(Video           : in out Video_Initialization_Handle;
		 Audio_Array     : in out Audio_Handle_Array;
		 Audio_Prefences : in out Audio_Initialization_Handle)
		is
		Result             : Integer := -1;
		Outer_Loop_Control : Boolean := TRUE;
		Inner_Loop_Control : Boolean := TRUE;
		Execution_Ticks    : Integer_32_Unsigned  := Integer_32_Unsigned(0);
		Ticks_To_Wait      : Integer_32_Unsigned  := Integer_32_Unsigned(1000 / Video.Max_Frame_Rate);
		begin
			Put_Line("Rotation Keys: ARROW_KEYS, NUMBERPAD_0, NUMBERPAD_PERIOD");
			Put_Line("Toggle Texturing: SPACEBAR");
			Initialize_Video
			(
				Video => Video
			);
			--Initialize_Audio
			--(
			--	Audio_Array     => Audio_Array,
			--	Audio_Prefences => Audio_Prefences
			--);
			Initialize_Scene;
			Initialize_Viewport
			(
				Width  => Integer(Video.Width),
				Height => Integer(Video.Height)
			);
			while Outer_Loop_Control loop
				Inner_Loop_Control := TRUE;
				Execution_Ticks    := Get_Ticks;
				while Outer_Loop_Control and Inner_Loop_Control loop
					Manage_Events
					(
						Loop_Control => Outer_Loop_Control,
						Video        => Video
					);
					Handle_Keypressed
					(
						Loop_Control => Outer_Loop_Control
					);
					if Ticks_To_Wait <= (Get_Ticks - Execution_Ticks) then
						Inner_Loop_Control := FALSE;
					end if;
				end loop;
				Update_Scene;
			end loop;
			--Finalize_Audio
			--(
			--	Audio_Array => Audio_Array
			--);
			Finalize_Video
			(
				Video => Video
			);
		end Run;
	----------
	-- Main --
	----------
	begin
		Run
		(
			Video           => DEFAULT_VIDEO_SETTINGS,
			Audio_Array     => DEFAULT_AUDIO_ARRAY,
			Audio_Prefences => DEFAULT_AUDIO_SETTINGS
		);
	end Game_Main;