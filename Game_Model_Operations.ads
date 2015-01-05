with AdaGL;                 use AdaGL;
with GL_H;                  use GL_H;
with GLU_H;                 use GLU_H;
--with Interfaces.C;          use Interfaces.C;
with Game_Framework;        use Game_Framework;
with Game_Mathmatics;       use Game_Mathmatics;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Streams.Stream_IO; use Ada.Streams.Stream_IO;
package Game_Model_Operations
	is
	MAXIMUM_VERTICES   : CONSTANT := 8000;
	MAXIMUM_POLYGONS   : CONSTANT := 8000;
	MODEL_3DS_MAIN     : CONSTANT := 16#4D4D#;
	MODEL_3DS_EDIT     : CONSTANT := 16#3D3D#;
	MODEL_3DS_MESH     : CONSTANT := 16#4100#;
	MODEL_3DS_NAME     : CONSTANT := 16#4000#;
	MODEL_3DS_VERTCIES : CONSTANT := 16#4110#;
	MODEL_3DS_POLYGONS : CONSTANT := 16#4120#;
	MODEL_3DS_MAPPING  : CONSTANT := 16#4140#;
	type Record_Vertex 
		is record
			X : Float_32;
			Y : Float_32;
			Z : Float_32;
		end record;
	type Record_Map_Coordinate
		is record
			U : Float_32;
			V : Float_32;
		end record;
	type Array_Polygon
		is array (1..MAXIMUM_POLYGONS, 1..3)
		of Integer_16_Unsigned;
	type Record_Array_Vertex
		is array (1..MAXIMUM_VERTICES)
		of Record_Vertex;
	type Record_Array_Map_Coordinate
		is array (1..MAXIMUM_VERTICES)
		of Record_Map_Coordinate;
	type Record_Model
		is record
			File_Name      : Unbounded_String;
			Name           : String (1..20);
			Vertices       : Integer_16_Unsigned;
			Polygons       : Integer_16_Unsigned;
			Texture_Id     : Integer_32_Unsigned;
			Vertex         : Record_Array_Vertex;
			Normal         : Record_Array_Vertex;
			Map_Coordinate : Record_Array_Map_Coordinate;
			Polygon        : Array_Polygon;
		end record;	
	type Record_Texture
		is record
			File_Name        : Unbounded_String;
			Width            : Integer_32_Signed;
			Height           : Integer_32_Signed;
			Pixels_Per_X     : Integer_32_Signed;
			Pixels_Per_Y     : Integer_32_Signed;
			Planes           : Integer_16_Unsigned;
			Bit_Count        : Integer_16_Unsigned;
			Compression      : Integer_32_Unsigned;
			Image_Size       : Integer_32_Unsigned;
			Used_Colors      : Integer_32_Unsigned;
			Important_Colors : Integer_32_Unsigned;
			Header_Size      : Integer_32_Unsigned;
		end record;		
	function Load_3ds_Model
		(File_Name_3ds : in String;
		 File_Name_Bmp : in String)
		return Record_Model;
	function Load_3ds_Mesh
		(File_Name : in String)
		return Record_Model;
	function Load_Bmp_Texture
		(File_Name : in String)
		return Integer_32_Unsigned;
private
	procedure Seek
		(File   : in File_Type;
		 Offset : in Integer_32_Unsigned);
end Game_Model_Operations;
