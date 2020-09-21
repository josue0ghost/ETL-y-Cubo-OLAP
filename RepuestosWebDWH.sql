IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name='RepuestosWebDWH')
	CREATE DATABASE RepuestosWebDWH
GO

USE RepuestosWebDWH
GO

/*
EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'RepuestosWebDWH'
GO
use [RepuestosWebDWH];
GO
use [master];
GO
USE [master]
GO
ALTER DATABASE [RepuestosWebDWH] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
USE [master]
GO
DROP DATABASE [RepuestosWebDWH]
GO
*/

--Cadenas
	--Tipo para cadenas largas
	CREATE TYPE [UDT_VarcharLargo] FROM VARCHAR(600)
	GO

	--Tipo para cadenas medianas
	CREATE TYPE [UDT_VarcharMediano] FROM VARCHAR(300)
	GO

	--Tipo para cadenas cortas
	CREATE TYPE [UDT_VarcharCorto] FROM VARCHAR(100)
	GO

	--Tipo para cadenas cortas
	CREATE TYPE [UDT_UnCaracter] FROM CHAR(1)
	GO

--Decimal
	--Tipo Decimal 6,2
	CREATE TYPE [UDT_Decimal6.2] FROM DECIMAL(6,2)
	GO

	--Tipo Decimal 5,2
	CREATE TYPE [UDT_Decimal5.2] FROM DECIMAL(5,2)
	GO

-- DATA TYPES PARA LLAVES SUBROGADAS
    --Tipo para SK entero: Surrogate Key
    CREATE TYPE [UDT_SK] FROM INT
    GO

    --Tipo para PK entero
    CREATE TYPE [UDT_PK] FROM INT
    GO

--Fechas
	CREATE TYPE [UDT_DateTime] FROM DATETIME
	GO

-- ********************** Schemas **********************
    CREATE SCHEMA Fact
    GO

    CREATE SCHEMA Dimension
    GO

-- ********************************************** MODELO ESTRELLA **********************************************
-- Dimensiones
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	CREATE TABLE Dimension.Fecha(
		DateKey INT NOT NULL

		PRIMARY KEY CLUSTERED
		(
			DateKey ASC
		) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF,
				ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	)ON [PRIMARY]
	GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	CREATE TABLE Dimension.Cliente(
		SK_Cliente [UDT_SK] IDENTITY(1,1) NOT NULL,
		ID_Cliente [UDT_SK] NULL
		PRIMARY KEY CLUSTERED
		(
			SK_Cliente ASC
		) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF,
				ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	)ON [PRIMARY]
	GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	CREATE TABLE Dimension.Ciudad(
		SK_Ciudad [UDT_SK] IDENTITY(1,1) NOT NULL,
		ID_Ciudad [UDT_SK] NULL
		PRIMARY KEY CLUSTERED
		(
			SK_Ciudad ASC
		) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF,
				ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	)ON [PRIMARY]
	GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	CREATE TABLE Dimension.Parte(
		SK_Parte [UDT_SK] IDENTITY(1,1) NOT NULL,
		ID_Parte [UDT_SK] NULL
		PRIMARY KEY CLUSTERED
		(
			SK_Parte ASC
		) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF,
				ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	)ON [PRIMARY]
	GO

-- Hechos
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	CREATE TABLE Fact.Ordenes(
		SK_Orden [UDT_SK] IDENTITY(1,1) NOT NULL,
		SK_Cliente [UDT_SK] NULL,
		SK_Ciudad [UDT_SK] NULL,
		SK_Parte [UDT_SK] NULL,
		DateKey INT NULL,
		ID_Orden [UDT_SK] NULL
		PRIMARY KEY CLUSTERED
		(
			SK_Orden ASC
		) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF,
				ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	)ON [PRIMARY]

-- ********************* Transformacion en modelo logico *********************
	-- Hecho
	ALTER TABLE Fact.Ordenes ADD ID_TotalOrdeb [UDT_PK]
	ALTER TABLE Fact.Ordenes ADD ID_Status [UDT_PK]
	ALTER TABLE Fact.Ordenes ADD FechaOrden [UDT_DateTime]
	ALTER TABLE Fact.Ordenes ADD Descuento [UDT_Decimal6.2]
	ALTER TABLE Fact.Ordenes ADD PorcentajeDescuento [UDT_Decimal6.2]
	ALTER TABLE Fact.Ordenes ADD ID_Cantidad [UDT_PK]
	ALTER TABLE Fact.Ordenes  WITH CHECK ADD FOREIGN KEY([DateKey])
		REFERENCES Dimension.Fecha ([DateKey])
	GO
	ALTER TABLE Fact.Ordenes  WITH CHECK ADD FOREIGN KEY([SK_Cliente])
		REFERENCES Dimension.Cliente ([SK_Cliente])
	GO
	ALTER TABLE Fact.Ordenes  WITH CHECK ADD FOREIGN KEY([SK_Ciudad])
		REFERENCES Dimension.Ciudad ([SK_Ciudad])
	GO
	ALTER TABLE Fact.Ordenes  WITH CHECK ADD FOREIGN KEY([SK_Parte])
		REFERENCES Dimension.Parte ([SK_Parte])
	GO

	--Dimension Fecha
	ALTER TABLE Dimension.Fecha ADD [Date] DATE NOT NULL
    ALTER TABLE Dimension.Fecha ADD [Day] TINYINT NOT NULL
	ALTER TABLE Dimension.Fecha ADD [DaySuffix] CHAR(2) NOT NULL
	ALTER TABLE Dimension.Fecha ADD [Weekday] TINYINT NOT NULL
	ALTER TABLE Dimension.Fecha ADD [WeekDayName] VARCHAR(10) NOT NULL
	ALTER TABLE Dimension.Fecha ADD [WeekDayName_Short] CHAR(3) NOT NULL
	ALTER TABLE Dimension.Fecha ADD [WeekDayName_FirstLetter] CHAR(1) NOT NULL
	ALTER TABLE Dimension.Fecha ADD [DOWInMonth] TINYINT NOT NULL
	ALTER TABLE Dimension.Fecha ADD [DayOfYear] SMALLINT NOT NULL
	ALTER TABLE Dimension.Fecha ADD [WeekOfMonth] TINYINT NOT NULL
	ALTER TABLE Dimension.Fecha ADD [WeekOfYear] TINYINT NOT NULL
	ALTER TABLE Dimension.Fecha ADD [Month] TINYINT NOT NULL
	ALTER TABLE Dimension.Fecha ADD [MonthName] VARCHAR(10) NOT NULL
	ALTER TABLE Dimension.Fecha ADD [MonthName_Short] CHAR(3) NOT NULL
	ALTER TABLE Dimension.Fecha ADD [MonthName_FirstLetter] CHAR(1) NOT NULL
	ALTER TABLE Dimension.Fecha ADD [Quarter] TINYINT NOT NULL
	ALTER TABLE Dimension.Fecha ADD [QuarterName] VARCHAR(6) NOT NULL
	ALTER TABLE Dimension.Fecha ADD [Year] INT NOT NULL
	ALTER TABLE Dimension.Fecha ADD [MMYYYY] CHAR(6) NOT NULL
	ALTER TABLE Dimension.Fecha ADD [MonthYear] CHAR(7) NOT NULL
    ALTER TABLE Dimension.Fecha ADD IsWeekend BIT NOT NULL

	--Dimension Cliente
	ALTER TABLE Dimension.Cliente ADD Nombre [UDT_VarcharCorto]
	ALTER TABLE Dimension.Cliente ADD Apellido [UDT_VarcharCorto]
	ALTER TABLE Dimension.Cliente ADD Genero [UDT_UnCaracter]
	ALTER TABLE Dimension.Cliente ADD Correo_Electronico [UDT_VarcharMediano]
	ALTER TABLE Dimension.Cliente ADD FechaNacimiento [UDT_DateTime]

	--Dimension Ciudad
	ALTER TABLE Dimension.Ciudad ADD Nombre [UDT_VarcharCorto]
	ALTER TABLE Dimension.Ciudad ADD CodigoPostal [UDT_PK]
	ALTER TABLE Dimension.Ciudad ADD ID_Region [UDT_PK]
	ALTER TABLE Dimension.Ciudad ADD ID_Pais [UDT_PK]

	--Dimension Parte
	ALTER TABLE Dimension.Parte ADD Nombre [UDT_VarcharCorto]
	ALTER TABLE Dimension.Parte ADD Precio [UDT_Decimal6.2]
	ALTER TABLE Dimension.Parte ADD ID_Categoria [UDT_PK]
	ALTER TABLE Dimension.Parte ADD ID_Linea [UDT_PK]
	
	-- Columnas SCD Tipo 2
	ALTER TABLE Dimension.Cliente	ADD FechaInicioValidez DATETIME NOT NULL DEFAULT(GETDATE())
	ALTER TABLE Dimension.Ciudad	ADD FechaInicioValidez DATETIME NOT NULL DEFAULT(GETDATE())
	ALTER TABLE Dimension.Parte		ADD FechaInicioValidez DATETIME NOT NULL DEFAULT(GETDATE())

	ALTER TABLE Dimension.Cliente	ADD FechaFinValidez DATETIME
	ALTER TABLE Dimension.Ciudad	ADD FechaFinValidez DATETIME
	ALTER TABLE Dimension.Parte		ADD FechaFinValidez DATETIME

	-- Campos de Auditoría
	ALTER TABLE Dimension.Cliente	ADD Fecha_Creacion DATETIME NOT NULL DEFAULT(GETDATE())
	ALTER TABLE Dimension.Ciudad	ADD Fecha_Creacion DATETIME NOT NULL DEFAULT(GETDATE())
	ALTER TABLE Dimension.Parte		ADD Fecha_Creacion DATETIME NOT NULL DEFAULT(GETDATE())
	ALTER TABLE Fact.Ordenes		ADD Fecha_Creacion DATETIME NOT NULL DEFAULT(GETDATE())

	ALTER TABLE Dimension.Cliente	ADD Fecha_Modificacion DATETIME
	ALTER TABLE Dimension.Ciudad	ADD Fecha_Modificacion DATETIME
	ALTER TABLE Dimension.Parte		ADD Fecha_Modificacion DATETIME
	ALTER TABLE Fact.Ordenes		ADD Fecha_Modificacion DATETIME

	ALTER TABLE Dimension.Cliente	ADD Usuario_Creacion NVARCHAR(100) NOT NULL DEFAULT(SUSER_NAME())
	ALTER TABLE Dimension.Ciudad	ADD Usuario_Creacion NVARCHAR(100) NOT NULL DEFAULT(SUSER_NAME())
	ALTER TABLE Dimension.Parte		ADD Usuario_Creacion NVARCHAR(100) NOT NULL DEFAULT(SUSER_NAME())
	ALTER TABLE Fact.Ordenes		ADD Usuario_Creacion NVARCHAR(100) NOT NULL DEFAULT(SUSER_NAME())

	ALTER TABLE Dimension.Cliente	ADD Usuario_Modificacion NVARCHAR(100)
	ALTER TABLE Dimension.Ciudad	ADD Usuario_Modificacion NVARCHAR(100)
	ALTER TABLE Dimension.Parte		ADD Usuario_Modificacion NVARCHAR(100)
	ALTER TABLE Fact.Ordenes		ADD Usuario_Modificacion NVARCHAR(100)

	-- Campos de linaje
	ALTER TABLE Dimension.Cliente	ADD ID_Batch VARCHAR(50)
	ALTER TABLE Dimension.Ciudad	ADD ID_Batch VARCHAR(50)
	ALTER TABLE Dimension.Parte		ADD ID_Batch VARCHAR(50)
	ALTER TABLE Fact.Ordenes		ADD ID_Batch VARCHAR(50)

	ALTER TABLE Dimension.Cliente	ADD ID_SourceSystem VARCHAR(50)
	ALTER TABLE Dimension.Ciudad	ADD ID_SourceSystem VARCHAR(50)
	ALTER TABLE Dimension.Parte		ADD ID_SourceSystem VARCHAR(50)
	ALTER TABLE Fact.Ordenes		ADD ID_SourceSystem VARCHAR(50)

-- ********************************************** MODELO COPO DE NIEVE **********************************************
	/*
	--Dimensiones
	CREATE TABLE Dimension.ClienteCN(
		SK_Cliente [UDT_SK] PRIMARY KEY IDENTITY
	)
	GO

	CREATE TABLE Dimension.Pais(
		SK_Pais [UDT_SK] PRIMARY KEY IDENTITY
	)
	GO

	CREATE TABLE Dimension.Region(
		SK_Region [UDT_SK] PRIMARY KEY IDENTITY,
		SK_Pais [UDT_SK] REFERENCES Dimension.Pais(SK_Pais)
	)
	GO

	CREATE TABLE Dimension.CiudadCN(
		SK_Ciudad [UDT_SK] PRIMARY KEY IDENTITY,
		SK_Region [UDT_SK] REFERENCES Dimension.Region(SK_Region)
	)
	GO	

	CREATE TABLE Dimension.Linea(
		SK_Line [UDT_SK] PRIMARY KEY IDENTITY
	)
	GO

	CREATE TABLE Dimension.Categoria(
		SK_Categoria [UDT_SK] PRIMARY KEY IDENTITY,
		SK_Line [UDT_SK] REFERENCES Dimension.Linea(SK_Line)
	)
	GO

	CREATE TABLE Dimension.ParteCN(
		SK_Parte [UDT_SK] PRIMARY KEY IDENTITY,
		SK_Categoria [UDT_SK] REFERENCES Dimension.Categoria(SK_Categoria)
	)
	GO

-- Hechos
	CREATE TABLE Fact.OrdenesCN(
		SK_Orden [UDT_SK] PRIMARY KEY IDENTITY,
		SK_Cliente [UDT_SK] REFERENCES Dimension.ClienteCN(SK_Cliente),
		SK_Ciudad [UDT_SK] REFERENCES Dimension.CiudadCN(SK_Ciudad),
		SK_Parte [UDT_SK] REFERENCES Dimension.ParteCN(SK_Parte),
		DateKey INT REFERENCES Dimension.Fecha(DateKey)
	)

--Transformacion en modelo logico
	--Hecho
	ALTER TABLE Fact.OrdenesCN ADD ID_TotalOrden [UDT_PK]
	ALTER TABLE Fact.OrdenesCN ADD FechaOrden [UDT_DateTime]
	ALTER TABLE Fact.OrdenesCN ADD ID_Status [UDT_PK]
	ALTER TABLE Fact.OrdenesCN ADD ID_Cantidad [UDT_PK]
	ALTER TABLE Fact.OrdenesCN ADD Descuento [UDT_Decimal6.2]
	ALTER TABLE Fact.OrdenesCN ADD PorcentajeDescuento [UDT_Decimal6.2]

	--Dimension Cliente
	ALTER TABLE Dimension.ClienteCN ADD Nombre [UDT_VarcharCorto]
	ALTER TABLE Dimension.ClienteCN ADD Apellido [UDT_VarcharCorto]
	ALTER TABLE Dimension.ClienteCN ADD Genero [UDT_UnCaracter]
	ALTER TABLE Dimension.ClienteCN ADD Correo [UDT_VarcharMediano]
	ALTER TABLE Dimension.ClienteCN ADD FechaNacimiento [UDT_DateTime]

	--Dimension Ciudad
	ALTER TABLE Dimension.CiudadCN ADD Nombre [UDT_VarcharCorto]
	ALTER TABLE Dimension.CiudadCN ADD CodigoPostal [UDT_PK]
	ALTER TABLE Dimension.CiudadCN ADD ID_Region [UDT_PK]
	
	--Dimension Region
	ALTER TABLE Dimension.Region ADD Nombre [UDT_VarcharCorto]
	ALTER TABLE Dimension.Region ADD ID_Pais [UDT_PK]

	--Dimension Pais
	ALTER TABLE Dimension.Pais ADD Nombre [UDT_VarcharCorto]

	--Dimension Parte
	ALTER TABLE Dimension.ParteCN ADD Nombre [UDT_VarcharCorto]
	ALTER TABLE Dimension.ParteCN ADD Precio [UDT_Decimal6.2]
	ALTER TABLE Dimension.ParteCN ADD Descripcion [UDT_VarcharMediano]
	ALTER TABLE Dimension.ParteCN ADD ID_Categoria [UDT_PK]
	
	--Dimension Categoria
	ALTER TABLE Dimension.Categoria ADD Nombre [UDT_VarcharCorto]
	ALTER TABLE Dimension.Categoria ADD Descripcion [UDT_VarcharMediano]
	ALTER TABLE Dimension.Categoria ADD ID_Linea [UDT_PK]

	--Dimension Linea
	ALTER TABLE Dimension.Linea ADD Nombre [UDT_VarcharCorto]
	ALTER TABLE Dimension.Linea ADD Descripcion [UDT_VarcharMediano]
	*/

/*
Que columnas son Medidas y de que tipo es cada columna?
ID_Cantidad - Aditiva
ID_TotalOrden - Aditiva
Descuento - Semiaditiva
PorcentajeDescuento - Semiaditiva
ID_Orden - No aditiva
*/

