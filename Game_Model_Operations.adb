package body Game_Model_Operations
	is
	--------------------
	-- Load_3ds_Model --
	--------------------
	function Load_3ds_Model
		(File_Name_3ds : String;
		 File_Name_Bmp : String)
		return Record_Model
		is
		Model : Record_Model;
		begin
			Model := Load_3ds_Mesh(File_Name_3ds);
			Model.Texture_Id := Load_Bmp_Texture(File_Name_Bmp);
			return Model;
		end Load_3ds_Model;
	-------------------
	-- Load_3ds_Mesh --
	-------------------
	function Load_3ds_Mesh
		(File_Name : String)
		return Record_Model
		is
		Model : Record_Model;
		begin
			---------
			Read_3ds:
			---------
				declare
				File         : File_Type;
				Chunk_Length : Integer_32_Unsigned;
				Chunk_Id     : Integer_16_Unsigned;
				begin
					Model.File_Name := To_Unbounded_String(File_Name);
					Open(File, In_File, File_Name);
					while not End_Of_File(File) loop
						Integer_16_Unsigned'Read(Stream(File), Chunk_Id);
						Integer_32_Unsigned'Read(Stream(File), Chunk_Length);
						case Chunk_Id is
							when MODEL_3DS_MAIN | MODEL_3DS_EDIT | MODEL_3DS_MESH =>
								null; --Enter chunk
							when MODEL_3DS_NAME =>
								for I in 1..20 loop
									Character'Read(Stream(File), Model.Name(I));
								exit when Model.Name(I) = Character'Val (0); end loop;
							when MODEL_3DS_VERTCIES =>
								Integer_16_Unsigned'Read(Stream(File), Model.Vertices);
								for I in 1..Integer(Model.Vertices) loop
									Float_32'Read(Stream(File), Model.Vertex(I).X);
									Float_32'Read(Stream(File), Model.Vertex(I).Y);
									Float_32'Read(Stream(File), Model.Vertex(I).z);
								end loop;
							when MODEL_3DS_POLYGONS =>
								--------------
								Read_Polygons:
								--------------
									declare
									Buffer : Integer_16_Unsigned;
									begin
										Integer_16_Unsigned'Read(Stream(File), Model.Polygons);
										for I in 1..Integer(Model.Polygons) loop
											Integer_16_Unsigned'Read(Stream(File), Model.Polygon(I, 1));
											Integer_16_Unsigned'Read(Stream(File), Model.Polygon(I, 2));
											Integer_16_Unsigned'Read(Stream(File), Model.Polygon(I, 3));
											Integer_16_Unsigned'Read(Stream(File), Buffer);
										end loop;
									end Read_Polygons;
							when MODEL_3DS_MAPPING =>
								-------------------------
								Read_Mapping_Coordinates:
								-------------------------
									declare
									Map_Coordinates : Integer_16_Unsigned;
									begin
										Integer_16_Unsigned'Read(Stream(File), Map_Coordinates);
										for I in 1..Integer(Map_Coordinates) loop
											Float_32'Read(Stream(File), Model.Map_Coordinate(I).U);
											Float_32'Read(Stream(File), Model.Map_Coordinate(I).V);
										end loop;
									end Read_Mapping_Coordinates;
							when others =>
								Seek(File, (Chunk_Length - 6));
						end case;
					end loop;
					Close(File);
				end Read_3ds;
			------------------------
			Calculate_Model_Normals:
			------------------------
				declare
				Connections   : array (1..MAXIMUM_VERTICES) of Float_32;
				Vector_3d     : array (1..6) of Vector_3d_Handle;
				Polygon_Index : Standard.Integer;
				begin
					for I in 1..Integer(Model.Vertices) loop
						Model.Normal(I).X := 0.0;
						Model.Normal(I).Y := 0.0;
						Model.Normal(I).z := 0.0;
						Connections(I)    := 0.0;
					end loop;
					for I in 1..Integer(Model.Polygons) loop
						for J in 1..3 loop
							Polygon_Index := Integer(Model.Polygon(I, J) + 1);
							Vector_3d(J).X := Model.Vertex(Polygon_Index).X;
							Vector_3d(J).Y := Model.Vertex(Polygon_Index).Y;
							Vector_3d(J).Z := Model.Vertex(Polygon_Index).Z;
						end loop;    
						Vector_3d(4) := Create_Vector_3d(Vector_3d(1), Vector_3d(2));
						Vector_3d(5) := Create_Vector_3d(Vector_3d(1), Vector_3d(3));
						Vector_3d(6) := Dot_Product(Vector_3d(4), Vector_3d(5));
						Vector_3d(6) := Normalize(Vector_3d(6));
						for J in 1..3 loop
							Polygon_Index := Integer(Model.Polygon(I, J) + 1);
							Connections(Polygon_Index) := Connections(Polygon_Index) + 1.0;
						end loop;
						for J in 1..3 loop
							Polygon_Index := Integer(Model.Polygon(I, J) + 1);
							Model.Normal(Polygon_Index).X := Model.Normal(Polygon_Index).X + Vector_3d(6).X;
							Model.Normal(Polygon_Index).Y := Model.Normal(Polygon_Index).Y + Vector_3d(6).Y;
							Model.Normal(Polygon_Index).Z := Model.Normal(Polygon_Index).Z + Vector_3d(6).Z;
						end loop;
					end loop;
					for I in 1..Integer(Model.Vertices) loop
						if Connections(I) > 0.0 then
							Model.Normal(I).X := Model.Normal(I).X / Connections(I);
							Model.Normal(I).Y := Model.Normal(I).Y / Connections(I);
							Model.Normal(I).Z := Model.Normal(I).Z / Connections(I);
						end if;
					end loop;
				end Calculate_Model_Normals;
			return Model;
		end Load_3ds_Mesh;
	----------------------
	-- Load_Bmp_Texture --
	----------------------
	function Load_Bmp_Texture
		(File_Name : String)
		return Integer_32_Unsigned
		is
		File       : File_Type;
		Texture    : Record_Texture;
		Texture_Id : Integer_32_Unsigned := 0;
		begin
			Open(File, In_File, File_Name);
			Seek(File, 18);
			Integer_32_Signed'Read(Stream(File), Texture.Width);
			Integer_32_Signed'Read(Stream(File), Texture.Height);
			Integer_16_Unsigned'Read(Stream(File), Texture.Planes);
			if Texture.Planes /= 1 then
				return -1;
			end if;
			Integer_16_Unsigned'Read(Stream(File),Texture.Bit_Count);
			if Texture.Bit_Count /= 24 then
				return -1;
			end if;
			Seek(File, 24);
			----------------
			Read_Bmp_Pixels:
			----------------
				declare
				I            : Integer_32_Signed          := 1;
				Bmp_Size     : Integer_32_Signed          := Integer_32_Signed(Texture.Width * Texture.Height * 3);
				Bmp_Pixels   : GLubyte_Array(1..Bmp_Size) := (others => 0);
				GLubyte_1    : GLubyte                    := 0;
				Return_Value : GLint                      := 0;
				begin
					for J in 1..Bmp_Size loop
						Glubyte'Read(stream(File), Bmp_Pixels(J));
					end loop;
					close(File);
					while I <= Bmp_Size loop --bgr -> rgb
						GLubyte_1         := Bmp_Pixels(I);
						Bmp_Pixels(I)     := Bmp_Pixels(I + 2);
						Bmp_Pixels(I + 2) := GLubyte_1;
						I := I + 3;
					end loop;
					glBindTexture(GL_TEXTURE_2D,Gluint(Texture_Id));
					glTexParameterf(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,    Float_32(GL_REPEAT));
					glTexParameterf(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,    Float_32(GL_REPEAT));
					glTexParameterf(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,Float_32(GL_LINEAR));
					glTexParameterf(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,Float_32(GL_LINEAR_MIPMAP_NEAREST));
					glTexEnvf(GL_TEXTURE_ENV,GL_TEXTURE_ENV_MODE,Float_32(GL_REPLACE));
					glTexImage2D(GL_TEXTURE_2D,0,3,Texture.Width,Texture.Height,0,GL_RGB,GL_UNSIGNED_BYTE,Bmp_Pixels);
					Return_Value := gluBuild2DMipmaps(GL_TEXTURE_2D,3,Texture.Width,Texture.Height,GL_RGB,GL_UNSIGNED_BYTE,Bmp_Pixels'address);
				end Read_Bmp_Pixels;
			return Texture_Id;
		end Load_Bmp_Texture;
	----------
	-- Seek --
	----------
	procedure Seek
		(File   : in File_Type;
		 Offset : in Integer_32_Unsigned)
		is
		Buffer : Integer_8_Unsigned := 0;
		begin
			for I in 1..Integer(Offset) loop
				Integer_8_Unsigned'Read(Stream(File), Buffer);
			end loop;
		end Seek;
end Game_Model_Operations;