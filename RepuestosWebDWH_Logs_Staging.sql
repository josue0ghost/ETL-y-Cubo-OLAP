USE RepuestosWebDWH
GO

-- **************************** INSERCIONES ****************************
INSERT INTO Dimension.Cliente
	(ID_Cliente, 
	 Nombre,
	 Apellido,
	 Genero,
	 Correo_Electronico, 
	 [FechaInicioValidez],
	 [FechaFinValidez],
	 Fecha_Creacion,
	 Usuario_Creacion,
	 Fecha_Modificacion,
	 Usuario_Modificacion,
	 ID_Batch,
	 ID_SourceSystem
	)
	SELECT C.ID_Cliente, 
			C.PrimerNombre, 
			C.PrimerApellido, 
			C.Genero,
			C.Correo_Electronico
			 --Columnas SCD Tipo 2
			  ,cast('2013-01-01' as datetime) as FechaInicioValidez
			  ,null AS FechaFinValidez
			  --Columnas Auditoria
			  ,GETDATE() AS FechaCreacion
			  ,CAST(SUSER_NAME() AS nvarchar(100)) AS UsuarioCreacion
			  ,GETDATE() AS FechaModificacion
			  ,CAST(SUSER_NAME() AS nvarchar(100)) AS UsuarioModificacion
			  --Columnas Linaje
			  ,'1-ETL' as ID_Batch
			  ,'RepuestosWeb' as ID_SourceSystem
	FROM RepuestosWeb.dbo.Clientes C

INSERT INTO Dimension.Ciudad
	(ID_Ciudad, 
	 ID_Region,
	 ID_Pais,
	 Nombre,
	 CodigoPostal,
	 [FechaInicioValidez],
	 [FechaFinValidez],
	 Fecha_Creacion,
	 Usuario_Creacion,
	 Fecha_Modificacion,
	 Usuario_Modificacion,
	 ID_Batch,
	 ID_SourceSystem
	)
	SELECT C.ID_Ciudad, 
			R.ID_Region,
			P.ID_Pais,
			C.Nombre,
			C.CodigoPostal
			 --Columnas SCD Tipo 2
			  ,cast('2013-01-01' as datetime) as FechaInicioValidez
			  ,null AS FechaFinValidez
			  --Columnas Auditoria
			  ,GETDATE() AS FechaCreacion
			  ,CAST(SUSER_NAME() AS nvarchar(100)) AS UsuarioCreacion
			  ,GETDATE() AS FechaModificacion
			  ,CAST(SUSER_NAME() AS nvarchar(100)) AS UsuarioModificacion
			  --Columnas Linaje
			  ,'1-ETL' as ID_Batch
			  ,'RepuestosWeb' as ID_SourceSystem

	FROM RepuestosWeb.dbo.Ciudad C
	INNER JOIN RepuestosWeb.dbo.Region R ON (C.ID_Region = R.ID_Region)
	INNER JOIN RepuestosWeb.dbo.Pais P ON (R.ID_Pais = P.ID_Pais)

INSERT INTO Dimension.Parte
	(ID_Parte, 
	 ID_Categoria,
	 ID_Linea,
	 Nombre,
	 Precio,
	 [FechaInicioValidez],
	 [FechaFinValidez],
	 Fecha_Creacion,
	 Usuario_Creacion,
	 Fecha_Modificacion,
	 Usuario_Modificacion,
	 ID_Batch,
	 ID_SourceSystem
	)
	SELECT P.ID_Partes, 
			C.ID_Categoria, 
			L.ID_Linea, 
			P.Nombre,
			P.Precio
			 --Columnas SCD Tipo 2
			  ,cast('2013-01-01' as datetime) as FechaInicioValidez
			  ,null AS FechaFinValidez
			  --Columnas Auditoria
			  ,GETDATE() AS FechaCreacion
			  ,CAST(SUSER_NAME() AS nvarchar(100)) AS UsuarioCreacion
			  ,GETDATE() AS FechaModificacion
			  ,CAST(SUSER_NAME() AS nvarchar(100)) AS UsuarioModificacion
			  --Columnas Linaje
			  ,'1-ETL' as ID_Batch
			  ,'RepuestosWeb' as ID_SourceSystem

	FROM RepuestosWeb.dbo.Partes P
	INNER JOIN RepuestosWeb.dbo.Categoria C ON (P.ID_Categoria = C.ID_Categoria)
	INNER JOIN RepuestosWeb.dbo.Linea L ON (L.ID_Linea = C.ID_Linea)

INSERT INTO Fact.Ordenes
	( 
	 SK_Parte, 
	 SK_Cliente,
	 SK_Ciudad,
	 DateKey,
	 ID_Orden,
	 ID_Cantidad,
	 ID_Status,
	 ID_TotalOrdeb,
	 Fecha_Creacion,
	 Usuario_Creacion,
	 Fecha_Modificacion,
	 Usuario_Modificacion,	 
	 ID_Batch,
	 ID_SourceSystem 
	)
	SELECT SK_Parte,
			SK_Cliente,
			SK_Ciudad,
			CAST( (CAST(YEAR(O.Fecha_Orden) AS VARCHAR(4)))+left('0'+CAST(MONTH(O.Fecha_Orden) AS VARCHAR(4)),2)+left('0'+(CAST(DAY(O.Fecha_Orden) AS VARCHAR(4))),2) AS INT)  as DateKey, 
			O.ID_Orden,
			DO.Cantidad,
			O.ID_StatusOrden,
			O.Total_Orden
			,GETDATE() AS FechaCreacion
			,SUSER_NAME() AS UsuarioCreacion
			,NULL AS FechaModificacion
			,NULL AS UsuarioModificacion
			--Columnas Linaje
			,'1-ETL' as ID_Batch
			,'RepuestosWeb' as ID_SourceSystem
	FROM RepuestosWeb.dbo.Orden O
		INNER JOIN RepuestosWeb.dbo.Detalle_orden DO ON (DO.ID_Orden = O.ID_Orden)
		INNER JOIN Dimension.Parte P ON (P.ID_Parte = DO.ID_Partes AND O.Fecha_Orden BETWEEN P.FechaInicioValidez AND ISNULL(P.FechaFinValidez, '9999-12-31'))
		INNER JOIN RepuestosWeb.dbo.Categoria C ON (C.ID_Categoria = P.ID_Categoria)
		INNER JOIN RepuestosWeb.dbo.Linea L ON (L.ID_Linea = C.ID_Categoria)
		INNER JOIN RepuestosWeb.dbo.StatusOrden S ON (S.ID_StatusOrden = O.ID_StatusOrden)
		INNER JOIN RepuestosWeb.dbo.Descuento D ON (D.ID_Descuento = DO.ID_Descuento)
		INNER JOIN Dimension.Ciudad Cd ON (Cd.ID_Ciudad = O.ID_Ciudad AND O.Fecha_Orden BETWEEN Cd.FechaInicioValidez AND ISNULL(Cd.FechaFinValidez, '9999-12-31'))
		INNER JOIN Dimension.Cliente Cl ON (Cl.ID_Cliente = O.ID_Cliente AND O.Fecha_Orden BETWEEN Cl.FechaInicioValidez AND ISNULL(Cl.FechaFinValidez, '9999-12-31'))
		LEFT JOIN Dimension.Fecha F ON(CAST( (CAST(YEAR(O.Fecha_Orden) AS VARCHAR(4)))+left('0'+CAST(MONTH(O.Fecha_Orden) AS VARCHAR(4)),2)+left('0'+(CAST(DAY(O.Fecha_Orden) AS VARCHAR(4))),2) AS INT)  = F.DateKey);

-- **************************** LOG TABLE ****************************
CREATE TABLE Factlog
(
	ID_Batch UNIQUEIDENTIFIER DEFAULT(NEWID()),
	FechaEjecucion DATETIME DEFAULT(GETDATE()),
	NuevosRegistros INT,
	CONSTRAINT [PK_FactLog] PRIMARY KEY
	(
		ID_Batch
	)
)
GO

	--Actualizamos nuestra columna de ID_batch
	UPDATE Fact.Ordenes
	SET ID_Batch = NEWID()
	GO

	--Transformamos nuestra columna a UNIQUEID
	ALTER TABLE Fact.Ordenes
	ALTER COLUMN ID_Batch UNIQUEIDENTIFIER
	GO

	--Insertamos el entry en factlog para el registro que ya existe
	INSERT INTO FactLog VALUES ((SELECT ID_Batch from Fact.Ordenes),(SELECT GETDATE() from Fact.Ordenes),1)
	go

	--Agregamos FK
	ALTER TABLE Fact.Ordenes ADD CONSTRAINT [FK_IDBatch] FOREIGN KEY (ID_Batch) 
	REFERENCES Factlog(ID_Batch)
	go

	create schema [staging]
	go

	DROP TABLE IF EXISTS staging.Ordenes
	GO

	CREATE TABLE staging.Ordenes(
		[ID_Ordenes] [int] NOT NULL,
		[ID_Cliente] [int] NULL,
		[ID_Region] [int] NULL,
		[ID_Parte] [int] NULL,
		[FechaOrden] [datetime] NULL,
		[Cantidad] [int] NULL,
		[PorcentajeDescuento] [decimal](2,2) NULL
	) ON [PRIMARY]
	GO

	--Query para llenar datos en Staging
	SELECT O.ID_Orden,
			O.ID_Cliente,
			Ci.ID_Region,
			P.ID_Partes,
			O.Fecha_Orden,
			DO.Cantidad,
			D.PorcentajeDescuento
	FROM RepuestosWeb.DBO.Orden O
		INNER JOIN RepuestosWeb.dbo.Detalle_orden DO ON (O.ID_Orden = DO.ID_Orden)
		INNER JOIN RepuestosWeb.dbo.Descuento D ON (D.ID_Descuento = DO.ID_Descuento)
		INNER JOIN RepuestosWeb.dbo.Partes P ON (DO.ID_Partes = P.ID_Partes)
		INNER JOIN RepuestosWeb.dbo.Ciudad Ci ON (Ci.ID_Ciudad = O.ID_Ciudad)
	go

	--Script de SP para MERGE
	CREATE PROCEDURE USP_MergeFact
	as
	BEGIN

		SET NOCOUNT ON;
		BEGIN TRY
			BEGIN TRAN
			DECLARE @NuevoGUIDInsert UNIQUEIDENTIFIER = NEWID()

			INSERT INTO FactLog
			VALUES (@NuevoGUIDInsert,getdate(),NULL)
		
			MERGE Fact.Ordenes AS T
			USING (
				SELECT [SK_Cliente], [SK_Ciudad], [SK_Parte], [DateKey], [ID_Ordenes], [FechaOrden], [PorcentajeDescuento], getdate() as Fecha_Creacion, 'ETL' as Usuario_Creacion, NULL as Fecha_Modificacion, NULL as Usuario_Modificacion, @NuevoGUIDINsert as ID_Batch, 'ssis' as ID_SourceSystem
				FROM staging.Ordenes R
					INNER JOIN Dimension.Cliente C ON(C.ID_Cliente = R.ID_Cliente and
														R.FechaOrden BETWEEN c.FechaInicioValidez AND ISNULL(c.FechaFinValidez, '9999-12-31')) 
					INNER JOIN Dimension.Ciudad CA ON(CA.ID_Region = R.ID_Region and
														R.FechaOrden BETWEEN CA.FechaInicioValidez AND ISNULL(CA.FechaFinValidez, '9999-12-31')) 
					INNER JOIN Dimension.Parte P ON (P.ID_Parte = R.ID_Parte and
														R.FechaOrden BETWEEN P.FechaInicioValidez AND ISNULL(P.FechaFinValidez, '9999-12-31')) 
					LEFT JOIN Dimension.Fecha F ON(CAST( (CAST(YEAR(R.FechaOrden) AS VARCHAR(4)))+left('0'+CAST(MONTH(R.FechaOrden) AS VARCHAR(4)),2)+left('0'+(CAST(DAY(R.FechaOrden) AS VARCHAR(4))),2) AS INT)  = F.DateKey)
					) AS S ON (S.ID_Ordenes = T.ID_Orden)

			WHEN NOT MATCHED BY TARGET THEN --No existe en Fact
			INSERT ([SK_Cliente], [SK_Ciudad], [SK_Parte], [DateKey], [ID_TotalOrdeb], [FechaOrden], [PorcentajeDescuento], [Fecha_Creacion], [Usuario_Creacion], [Fecha_Modificacion], [Usuario_Modificacion], [ID_Batch], [ID_SourceSystem])
			VALUES (S.[SK_Cliente], S.[SK_Ciudad], S.[SK_Parte], S.[DateKey], S.[ID_Ordenes], S.[FechaOrden], S.[PorcentajeDescuento], S.[Fecha_Creacion], S.[Usuario_Creacion], S.[Fecha_Modificacion], S.[Usuario_Modificacion], S.[ID_Batch], S.[ID_SourceSystem]);

			UPDATE FactLog
			SET NuevosRegistros=@@ROWCOUNT
			WHERE ID_Batch = @NuevoGUIDInsert

			COMMIT
		END TRY
		BEGIN CATCH
			SELECT @@ERROR,'Ocurrio el siguiente error: '+ERROR_MESSAGE()
			IF (@@TRANCOUNT>0)
				ROLLBACK;
		END CATCH

	END
	go
