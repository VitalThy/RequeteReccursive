CREATE TABLE [dbo].[Utilisateur](
	[Superieur] [varchar](10) NULL,
	[Utilisateur] [varchar](10) NOT NULL,
 CONSTRAINT [PK_Utilisateur] PRIMARY KEY CLUSTERED 
(
	[Utilisateur] ASC
)) ON [PRIMARY]
GO

INSERT INTO dbo.Utilisateur (Superieur, Utilisateur) VALUES('LLE','CBO')
INSERT INTO dbo.Utilisateur (Superieur, Utilisateur) VALUES(NULL,'JBR')
INSERT INTO dbo.Utilisateur (Superieur, Utilisateur) VALUES('LTH','LCO')
INSERT INTO dbo.Utilisateur (Superieur, Utilisateur) VALUES('JBR','LLE')
INSERT INTO dbo.Utilisateur (Superieur, Utilisateur) VALUES('JBR','LTH')
INSERT INTO dbo.Utilisateur (Superieur, Utilisateur) VALUES('LLE','NAF')
INSERT INTO dbo.Utilisateur (Superieur, Utilisateur) VALUES('JBR','NDE')
INSERT INTO dbo.Utilisateur (Superieur, Utilisateur) VALUES('NDE','RBO')
INSERT INTO dbo.Utilisateur (Superieur, Utilisateur) VALUES('NDE','TCO')
INSERT INTO dbo.Utilisateur (Superieur, Utilisateur) VALUES('LTH','VDE')

GO

CREATE OR ALTER VIEW V_SNLHierarchiqueParCTE AS 
-- Table CTE Préfixé par WITH
WITH R AS (
  -- 1ère partie initialisation. Comme la Table CTE va s'autoappeler. Il faut une première condition pour l'alimenter avec des données
  SELECT Utilisateur,
         Superieur AyantDroit 
  FROM Utilisateur
  WHERE Superieur IS NOT NULL
  UNION ALL
  -- Ici la table va s'autoappeler 
  SELECT R.Utilisateur,
         U.Superieur AyantDroit
  FROM R 
  INNER JOIN Utilisateur U ON U.Utilisateur = R.AyantDroit 
  WHERE U.Superieur IS NOT NULL
)

-- Sélection finale
SELECT * FROM R
ORDER BY AyantDroit

GO

CREATE OR ALTER FUNCTION fn_Reccursif 
(	
	-- Utilisateur appelé
	@U varchar(50)
)
-- Le retour de la fonction : Un dataset contenant un utilisateur et son responsable de niveau n
RETURNS @SnlHierarchique TABLE (
    Utilisateur varchar(50),
	AyantDroit varchar(50)
)
AS
BEGIN 

    
	DECLARE @Superieur VARCHAR(50) 

	-- Récupération du responsable de l'utilisateur fourni en paramètre
	SELECT @Superieur = Superieur FROM Utilisateur WHERE Utilisateur = @U
	
	IF @Superieur IS NULL BEGIN 
	  -- Si le responsable est null, on ne renvoit que l'utilisateur
	  INSERT INTO @SnlHierarchique
	  SELECT Utilisateur, Superieur AyantDroit FROM Utilisateur WHERE Utilisateur = @U	  
	END ELSE BEGIN
	  -- Si le responsable n'est pas null
	  INSERT INTO @SnlHierarchique
	  -- On renvoi l'utilisateur
	  SELECT Utilisateur, Superieur AyantDroit FROM Utilisateur WHERE Utilisateur = @U
	  UNION 
	  -- + la liste des utilisateurs renvoyées par l'appel de la propre fonction mais 
	  -- cette fois ci en paramètre on met le responsable de l'utilisateur
	  SELECT Utilisateur, AyantDroit FROM fn_Reccursif(@Superieur) 
    END
	RETURN

END
GO

CREATE OR ALTER VIEW V_SNLHierarchiqueParFonction AS 
SELECT r.Utilisateur, r.AyantDroit FROM Utilisateur
CROSS APPLY [dbo].[fn_Reccursif] (
   Utilisateur) r
WHERE AyantDroit IS NOT NULL



