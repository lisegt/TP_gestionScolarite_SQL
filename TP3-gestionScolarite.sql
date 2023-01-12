-- 1. Création BDD 
-- \i /Users/lise/Documents/ISIS/FIE3/S5/BDD/SQL/TP3/creationBDscolarite.sql

-- 2.Remplir la table Département en utilisant une séquence pour générer automatiquement le numéro de département.

CREATE SEQUENCE sequence_noDep MINVALUE 1;
INSERT INTO Departement VALUES 
(NEXTVAL('sequence_noDep'),'ISIS'),
(NEXTVAL('sequence_noDep'),'INFO'),
(NEXTVAL('sequence_noDep'),'SHS');

SELECT * FROM departement;

-- 3. Peuplement BDD

-- \i /Users/lise/Documents/ISIS/FIE3/S5/BDD/SQL/TP2/BDScolariteInsertion.sql

-- 4. Créer une vue permettant de visualiser le nombre de réservation par enseignant.
CREATE OR REPLACE VIEW NbReservationParEnseignant (Nom_Enseignant, NbReservation) AS
SELECT enseignant.nom, COUNT(reservation_id) AS "Nombre de réservations"
FROM enseignant INNER JOIN reservation USING (enseignant_id)
GROUP BY enseignant_id, enseignant.nom ;

-- 5. Quels sont les enseignants ayant le plus de réservations
SELECT *
FROM NbReservationParEnseignant
WHERE NbReservation >= ALL (SELECT NbReservation
                        FROM NbReservationParEnseignant);

-- 6. Quels sont les noms et les prénoms des enseignants n’ayant aucune réservation ?
SELECT enseignant.nom, enseignant.prenom
FROM enseignant
WHERE UPPER(enseignant.nom) NOT IN (SELECT UPPER(Nom_Enseignant)
                                    FROM NbReservationParEnseignant);

(SELECT enseignant.nom FROM enseignant)
EXCEPT
(SELECT Nom_Enseignant FROM NbReservationParEnseignant);

SELECT nom, prenom
FROM enseignant
WHERE NOT EXISTS (SELECT * FROM reservation
                    WHERE reservation.enseignant_id = enseignant.enseignant_id);


-- 7. Créer la vue Info_Enseignant (Matricule, Nom, Prenom, email) à partir de la table Enseignant. Vérifier son contenu.
CREATE OR REPLACE VIEW Info_Enseignant (Matricule, Nom, Prenom, email) AS
SELECT enseignant_id, enseignant.nom, enseignant.prenom, enseignant.email
FROM enseignant;

SELECT * FROM Info_Enseignant ;

-- 8. À travers la vue Info_Enseignant, modifier l’adresse mel de l’enseignant Lamine du « elyes.lamine@univ-jfc.fr » 
-- en «elyes.lamine@gmail.com». Consulter le contenu de la vue Info_Enseignant et de la table Enseignant.
UPDATE Info_Enseignant
SET email='elyes.lamine@gmail.com'
WHERE UPPER(nom)='LAMINE';

CREATE OR REPLACE RULE "RegleModifEmail"
AS ON UPDATE TO Info_Enseignant
DO INSTEAD UPDATE Enseignant
SET email = new.email 
WHERE UPPER(nom) = UPPER(new.nom);

-- 9. Insérez à partir de la vue Info_Enseignant un nouvel enseignant.
CREATE OR REPLACE RULE "RegleAjoutEnseignant"
AS ON INSERT TO Info_Enseignant
DO INSTEAD INSERT INTO Enseignant
VALUES (new.Matricule, 1, new.nom, new.prenom, NULL, NULL, NULL, new.Email);

INSERT INTO Info_Enseignant
VALUES (10,'Gauthier', 'Lise', 'lise.gauthier@etud.univ-jfc.fr');

-- 10. Créer une fonction Sql GetSalleCapaciteSuperieurA permettant de récupérer la liste des salles 
-- ayant une capacité supérieure à une certaine valeur donnée en paramètre.
CREATE OR REPLACE FUNCTION GetSalleCapaciteSuperieureA(cap int) 
RETURNS SETOF salle AS $$
DECLARE
 s salle%rowtype;
BEGIN
    FOR s IN SELECT * FROM salle WHERE salle.capacite > cap
    LOOP
        RETURN NEXT s; 
    END LOOP ;
    RETURN;
END $$ LANGUAGE 'plpgsql';

-- OU RETURNS SETOF RECORD 

CREATE OR REPLACE FUNCTION GetSalleCapaciteSuperieureA2(cap int) 
RETURNS SETOF record 
AS $$

SELECT * FROM salle WHERE salle.capacite > cap ;

$$ LANGUAGE 'sql';

-- test de la fonction
SELECT * FROM GetSalleCapaciteSuperieureA(100) ;

-- 11. Créer une fonction Sql GetDepartement_ID permettant de récupérer l'identificateur du département 
-- à partir de son nom donné en paramètre. 
-- Avec boucle
CREATE OR REPLACE FUNCTION GetDepartement_ID(nomDep Departement.nom_departement%type)
RETURNS Departement.departement_id%type AS $$
DECLARE
    d departement%rowtype;
BEGIN 
    FOR d IN SELECT * FROM departement WHERE departement.nom_departement=nomDep
    LOOP
        RETURN d.departement_id;
    END LOOP ;
END $$ LANGUAGE 'plpgsql';

-- Sans boucle
CREATE OR REPLACE FUNCTION GetDepartement_ID2(nomDep Departement.nom_departement%type)
RETURNS Departement.departement_id%type AS $$
DECLARE
    res departement.departement_id%type;
BEGIN 
    SELECT into res departement_id FROM departement WHERE departement.nom_departement=nomDep ;
    RETURN res;
END $$ LANGUAGE 'plpgsql';

-- test de la fonction
SELECT * FROM GetDepartement_ID('ISIS');
SELECT * FROM GetDepartement_ID2('ISIS');

-- Tester cette fonction pour afficher les nom et prénom des enseignants du département « ISIS »
SELECT Enseignant.nom, Enseignant.prenom
FROM enseignant
WHERE enseignant.departement_id=GetDepartement_ID('ISIS');

-- 12. Écrire une fonction pgsql SonDepartement qui admette un numéro d'enseignant en paramètre 
-- et qui renvoie comme résultat le nom du département de l'enseignant. 
-- Avec boucle
CREATE OR REPLACE FUNCTION SonDepartement(numEnseignant Enseignant.enseignant_id%type)
RETURNS departement.nom_departement%type AS $$
DECLARE res Departement.nom_departement%type;
BEGIN
    FOR res IN SELECT Departement.nom_departement FROM Enseignant, Departement
                WHERE Enseignant.departement_id=Departement.departement_id
                AND enseignant.enseignant_id=numEnseignant
    LOOP
        RETURN res;
    END LOOP ;
END $$ LANGUAGE 'plpgsql';

-- Sans boucle
CREATE OR REPLACE FUNCTION SonDepartement2(numEnseignant Enseignant.enseignant_id%type)
RETURNS departement.nom_departement%type AS $$
DECLARE res Departement.nom_departement%type;
BEGIN
    SELECT into res Departement.nom_departement FROM Enseignant, Departement
                WHERE Enseignant.departement_id=Departement.departement_id
                AND enseignant.enseignant_id=numEnseignant ;
    RETURN res;
END $$ LANGUAGE 'plpgsql';

-- Tester la fonction.
SELECT * FROM SonDepartement(10);
SELECT * FROM SonDepartement2(10);

-- 13. Écrire en pl/pgsql une fonction MoyCapacite sans paramètre qui renvoie la capacité moyenne des salles.
-- Avec boucle
CREATE OR REPLACE FUNCTION MoyCapacite()
RETURNS float AS $$
DECLARE 
    s salle.capacite%type;
    sum s%type := 0;
    i integer := 0;
BEGIN
    FOR s IN SELECT salle.capacite FROM salle
    LOOP
        sum := sum + s;
        i := i + 1;
    END LOOP ;
    RETURN sum/i :: float ;
END $$ LANGUAGE 'plpgsql';

-- Sans boucle 
CREATE OR REPLACE FUNCTION MoyCapacite2()
RETURNS float AS $$
DECLARE 
    res float;
BEGIN
    SELECT INTO res AVG(capacite) FROM salle ;
    RETURN res;
END $$ LANGUAGE 'plpgsql';

-- Test
SELECT * FROM MoyCapacite();
SELECT * FROM MoyCapacite2();

-- 14. Utiliser la fonction pgsql MoyCapacite pour afficher les salles ( batiment, numero et capacité ) qui ont une capacité superieur à la moyenne,
SELECT salle.batiment, salle.numero_salle, salle.capacite
FROM salle
WHERE salle.capacite > MoyCapacite();

-- 15. Utiliser la fonction pgsql MoyCapacite pour afficher les salles ( batiment, numero et capacité ) qui ont une capacité 
-- est égal à la capacité moyenne à 15% près (c'est-à-dire ceux dont la capacité est comprise entre 85% et 115% de la capacité moyenne).
SELECT salle.batiment, salle.numero_salle, salle.capacite
FROM salle
WHERE salle.capacite BETWEEN 0.85*MoyCapacite() AND 1.15*MoyCapacite();

-- 16. Écrire une fonction pgsql Collegues qui admet un numéro d'enseignant en paramètre et qui renvoie comme résultat le nom et le prénom de ses collègues 
-- du même département, l'enseignant lui-même ne devant pas faire partie de la liste des collègues.
CREATE TYPE Nom_Et_Prenom AS (nom VARCHAR(25), prenom VARCHAR(25));

CREATE OR REPLACE FUNCTION Collegues(numEnseignant enseignant.enseignant_id%type) 
RETURNS SETOF Nom_Et_Prenom AS $$
DECLARE
    e Nom_Et_Prenom;
BEGIN
    FOR e IN SELECT enseignant.nom, enseignant.prenom FROM enseignant
                WHERE enseignant.departement_id = (SELECT enseignant.departement_id FROM enseignant WHERE enseignant_id=numEnseignant) 
                AND enseignant.enseignant_id <> numEnseignant
    LOOP
        RETURN NEXT e;
    END LOOP ; 
    RETURN;
END $$ LANGUAGE 'plpgsql';

-- Test fonction
SELECT * FROM Collegues(10);

-- 17. Écrire une fonction pgsql numlignes qui renvoie le nombre de lignes de la table dont le nom est passé en paramètre.

-- PB : on ne peut pas passer de nom de table en paramètre
CREATE OR REPLACE FUNCTION numlignes(nomDeTable VARCHAR(20))
RETURNS integer AS $$
DECLARE 
    l nomDeTable%rowtype;
    i integer := 0;
BEGIN
    FOR l IN SELECT * FROM nomDeTable
    LOOP
        i := i + 1;
    END LOOP ;
    RETURN i ;
END $$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION numlignes2(nomDeTable VARCHAR(20))
RETURNS integer AS $$
DECLARE 
    res integer;
BEGIN
    EXECUTE 'SELECT COUNT(*) FROM ' || nomDeTable  INTO res;
    RETURN res;
END $$ LANGUAGE 'plpgsql';

SELECT * FROM numlignes2('enseignant');
SELECT * from enseignant;
