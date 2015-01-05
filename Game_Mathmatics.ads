with Ada.Numerics.Generic_Elementary_Functions;
package Game_Mathmatics
	is
	package Float_Elementary_Functions
		is new Ada.Numerics.Generic_Elementary_Functions(float);
		use Float_Elementary_Functions;
	type Matrix_4x4_Handle is 
		array (0..3,0..3)
		of Float;
	type Matrix_1x4_Handle is
		array (0..3)
		of Float;
	type Trigonometry_Table_Handle is 
		array (0..35999)
		of Float;
	type Vector_3d_Handle is 
		record
			x : Float;
			y : Float;
			z : Float;
		end record;
	PI                             : CONSTANT Float                    := 3.141_592_653_589_793;
	FLAG_INITIALIZATION_MATHMATICS :          Boolean                  := FALSE;
	Cosine_Table                   :          Trigonometry_Table_Handle;
	Sine_Table                     :          Trigonometry_Table_Handle;
	procedure Initilize_Mathmatics;
	function Create_Identity_Matrix_4x4
		return Matrix_4x4_Handle;
	function Transpose
		(Matrix_4x4_Source : in Matrix_4x4_Handle)
		return Matrix_4x4_Handle;
	function "*"
		(Left  : in Matrix_4x4_Handle;
		 Right : in Matrix_1x4_Handle)
		return Matrix_1x4_Handle;
	function "*"
		(Left  : in Matrix_4x4_Handle;
		 Right : in Matrix_4x4_Handle)
		return Matrix_4x4_Handle;
	function "*"
		(Left  : in Matrix_1x4_Handle;
		 Right : in Matrix_4x4_Handle)
		return Matrix_1x4_Handle;
	function "+"
		(Left  : in Vector_3d_Handle;
		 Right : in Vector_3d_Handle)
		return Vector_3d_Handle;
	function "-"
		(Left  : in Vector_3d_Handle;
		 Right : in Vector_3d_Handle)
		return Vector_3d_Handle;
	function Create_Vector_3d
		(Vector_3d_Start : in Vector_3d_Handle;
		 Vector_3d_End   : in Vector_3d_Handle)
		return Vector_3d_Handle;
	function Length
		(Vector_3d : in Vector_3d_Handle)
		return float;
	function Scalar_Product
		(Vector_3d_Source_1 : in Vector_3d_Handle;
		 Vector_3d_Source_2 : in Vector_3d_Handle)
		return float;
	function Normalize
		(Vector_3d : in Vector_3d_Handle)
		return Vector_3d_Handle;
	function Dot_Product
		(Vector_3d_Source_1 : in Vector_3d_Handle;
		 Vector_3d_Source_2 : in Vector_3d_Handle)
		return Vector_3d_Handle;
end Game_Mathmatics;
