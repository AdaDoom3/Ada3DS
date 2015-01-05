package body Game_Mathmatics
	is
	--------------------------
	-- Initilize_Mathmatics --
	--------------------------
	procedure Initilize_Mathmatics
	is
	begin
		for i in 0 .. 35999 loop
			Cosine_Table(i) := float(Cos(float(i) * PI / 18000.0));
		end loop;
		for i in 0 .. 35999 loop
			Sine_Table(i) := float(Sin(float(i) * PI / 18000.0));
		end loop;
		FLAG_INITIALIZATION_MATHMATICS := TRUE;
	end Initilize_Mathmatics;
	--------------------------------
	-- Create_Identity_Matrix_4x4 --
	--------------------------------
	function Create_Identity_Matrix_4x4
		return Matrix_4x4_Handle
		is
		Matrix : Matrix_4x4_Handle;
		begin
			for i in 0..3 loop
				for j in 0..3 loop
					if i = j then
						Matrix(i,j) := 1.0;
					else 
						Matrix(i,j) := 0.0;
					end if;
				end loop;
			end loop;
			return Matrix;
		end Create_Identity_Matrix_4x4;
	----------------------
	-- Create_Vector_3d --
	----------------------
	function Create_Vector_3d
		(Vector_3d_Start : in Vector_3d_Handle;
		 Vector_3d_End   : in Vector_3d_Handle)
		return Vector_3d_Handle
		is
		Vector_3d_Destination : Vector_3d_Handle;
		begin
			Vector_3d_Destination.x := Vector_3d_End.x - Vector_3d_Start.x;
			Vector_3d_Destination.y := Vector_3d_End.y - Vector_3d_Start.y;
			Vector_3d_Destination.z := Vector_3d_End.z - Vector_3d_Start.z;
			return Vector_3d_Destination;
		end Create_Vector_3d;
	---------
	-- Add --
	---------
	--Vector 3d by 3d
	function "+"
		(Left  : in Vector_3d_Handle;
		 Right : in Vector_3d_Handle)
		return Vector_3d_Handle
		is
		Vector_3d_Destination : Vector_3d_Handle;
		begin
			Vector_3d_Destination.x := Left.x    + Right.x;
			Vector_3d_Destination.y := Left.y    + Right.y;
			Vector_3d_Destination.z := Vector_3d_Destination.z + Vector_3d_Destination.z;
			return Vector_3d_Destination;
		end "+";
	--------------
	-- Subtract --
	--------------
	--Vector 3d by 3d
	function "-"
		(Left  : in Vector_3d_Handle;
		 Right : in Vector_3d_Handle)
		 return Vector_3d_Handle
		is
		Vector_3d_Destination : Vector_3d_Handle;
		begin
			Vector_3d_Destination.x := Left.x    - Right.x;
			Vector_3d_Destination.y := Left.y    - Right.y;
			Vector_3d_Destination.z := Vector_3d_Destination.z - Vector_3d_Destination.z;
			return Vector_3d_Destination;
		end "-";
	--------------
	-- Multiply --
	--------------
	--Matrix 4x4 by 1x4
	function "*"
		(Left  : in Matrix_4x4_Handle;
	 	 Right : in Matrix_1x4_Handle)
		return Matrix_1x4_Handle
		is
		sum : float := 0.0;
		Matrix_1x4_Destination : Matrix_1x4_Handle;
		begin
			for i in 0..3 loop
				sum := 0.0;
				for j in 0..3 loop
					sum := sum + (Right(j) * Left(j,i));
					Matrix_1x4_Destination(i) := sum;
				end loop;
			end loop;
			return Matrix_1x4_Destination;
		end "*";
	--Matrix 1x4 by 4x4
	function "*"
		(Left  : in Matrix_1x4_Handle;
		 Right : in Matrix_4x4_Handle)
		return Matrix_1x4_Handle
		is
		sum : float := 0.0;
		Matrix_1x4_Destination : Matrix_1x4_Handle;
		begin
			for i in 0..3 loop
				sum := 0.0;
				for j in 0..3 loop
					sum := sum + (Left(j) * Right(j,i));
					Matrix_1x4_Destination(i) := sum;
				end loop;
			end loop;
			return Matrix_1x4_Destination;
		end "*";
	--Matrix 4x4 by 4x4
	function "*"
		(Left  : in Matrix_4x4_Handle;
		 Right : in Matrix_4x4_Handle)
		return Matrix_4x4_Handle
		is
		Matrix_4x4_Destination : Matrix_4x4_Handle;
		sum : float := 0.0;
		begin
			for i in 0..3 loop
				for j in 0..3 loop
					sum := 0.0;
					for k in 0..3 loop
						sum := sum + (Left(i,k) * Right(k,j));
						Matrix_4x4_Destination (i,j) := sum;
					end loop;
				end loop;
			end loop;
			return Matrix_4x4_Destination;
		end "*";
	---------------
	-- Transpose --
	---------------
	--Matrix 4x4
	function Transpose
		(Matrix_4x4_Source : in Matrix_4x4_Handle)
		return Matrix_4x4_Handle
		is
		Matrix_4x4_Destination : Matrix_4x4_Handle;
		begin
			for i in 0..2 loop
				for j in 0..2 loop
					Matrix_4x4_Destination(i,j) := Matrix_4x4_Source(j,i);
				end loop;
			end loop;
			return Matrix_4x4_Destination;
		end Transpose;
	------------
	-- Length --
	------------
	--Vector 3d
	function Length
		(Vector_3d : in Vector_3d_Handle)
		return float
		is
		begin
			return 
				float
				(
					sqrt
					(
						Vector_3d.x * Vector_3d.x +
						Vector_3d.y * Vector_3d.y +
						Vector_3d.z * Vector_3d.Z
					)
				);
		end Length;
	--------------------
	-- Scalar_Product --
	--------------------
	--Vector 3d by 3d
	function Scalar_Product
		(Vector_3d_Source_1 : in Vector_3d_Handle;
		 Vector_3d_Source_2 : in Vector_3d_Handle)
		return float
		is
		begin
			return
			(
				float
				(
					(Vector_3d_Source_1.x + Vector_3d_Source_2.x) *
					(Vector_3d_Source_1.y + Vector_3d_Source_2.y) *
					(Vector_3d_Source_1.z + Vector_3d_Source_2.z)
				)
			);
		end Scalar_Product;
	---------------
	-- Normalize --
	---------------
	--Vector 3d
	function Normalize
		(Vector_3d : in Vector_3d_Handle)
		return Vector_3d_Handle
		is
		Vector_3d_Normalized : Vector_3d_Handle;
		Length               : float;
		begin
			length := Game_Mathmatics.Length(Vector_3d);
			if length = 0.0 then
				length := 1.0;
			end if;
			Vector_3d_Normalized.x := Vector_3d.x / length;
			Vector_3d_Normalized.y := Vector_3d.y / length;
			Vector_3d_Normalized.z := Vector_3d.z / length;
			return Vector_3d_Normalized;
		end Normalize;
	-----------------
	-- Dot_Product --
	-----------------
	--Vector 3d by 3d
	function Dot_Product
		(Vector_3d_Source_1 : in Vector_3d_Handle;
		 Vector_3d_Source_2 : in Vector_3d_Handle)
		return Vector_3d_Handle
		is
		Vector_3d_Destination : Vector_3d_Handle;
		begin
			Vector_3d_Destination.x :=
				(Vector_3d_Source_1.y * Vector_3d_Source_2.z) - 
				(Vector_3d_Source_1.z * Vector_3d_Source_2.y);
			Vector_3d_Destination.y := 
				(Vector_3d_Source_1.x * Vector_3d_Source_2.z) - 
				(Vector_3d_Source_1.z * Vector_3d_Source_2.x);
			Vector_3d_Destination.z := 
				(Vector_3d_Source_1.x * Vector_3d_Source_2.y) - 
				(Vector_3d_Source_1.y * Vector_3d_Source_2.x);
			return Vector_3d_Destination;
		end Dot_Product;
end Game_Mathmatics;