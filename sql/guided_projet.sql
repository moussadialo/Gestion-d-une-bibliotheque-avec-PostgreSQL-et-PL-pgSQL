/* =====================================================
   PROJET PL/pgSQL - GESTION D'UNE BIBLIOTHEQUE
   Partie 1 : Fonctions et triggers guidés
   ===================================================== */


/* =====================================================
   1. FONCTIONS DE BASE
   ===================================================== */
/* 1.1 Ajouter un auteur */
CREATE OR REPLACE FUNCTION ajouter_auteur(
    p_nom VARCHAR(60), 
    p_pays VARCHAR(40)
)
RETURNS VOID AS $$
BEGIN
    -- Vérifier le nom
    IF p_nom IS NULL OR TRIM(p_nom) = '' THEN
        RAISE EXCEPTION 'Le nom est obligatoire et ne peut être vide';
    END IF;
    -- Vérifier le pays
    IF p_pays IS NULL OR TRIM(p_pays) = '' THEN
        RAISE EXCEPTION 'Le pays est obligatoire et ne peut être vide';
    END IF;

    INSERT INTO auteur(nom, pays) VALUES (p_nom, p_pays);
END $$ 
LANGUAGE PLPGSQL;

/* 1.2 Ajouter un livre */
CREATE OR REPLACE FUNCTION ajouter_livre(
    p_titre VARCHAR,
    p_id_auteur INT,
    p_id_categorie INT,
    p_annee INT,
    p_nb_exemplaires INT
)
RETURNS VOID AS $$
BEGIN
    -- Vérifier le titre
    IF p_titre IS NULL OR TRIM(p_titre) = '' THEN
        RAISE EXCEPTION 'Le titre est obligatoire et ne peut être vide';
    END IF;

    -- Vérifier l'identifiant de l'auteur
    IF p_id_auteur IS NULL THEN
        RAISE EXCEPTION 'L''identifiant de l''auteur est obligatoire';
    END IF;

    -- Vérifier l'identifiant de la catégorie
    IF p_id_categorie IS NULL THEN
        RAISE EXCEPTION 'L''identifiant de la catégorie est obligatoire';
    END IF;

    -- Vérifier l'existence de l'auteur
    IF NOT EXISTS (
        SELECT 1 FROM auteur WHERE id_auteur = p_id_auteur
    ) THEN
        RAISE EXCEPTION 'Cet auteur n''existe pas';
    END IF;

    -- Vérifier l'existence de la catégorie
    IF NOT EXISTS (
        SELECT 1 FROM categorie WHERE id_categorie = p_id_categorie
    ) THEN
        RAISE EXCEPTION 'Cette catégorie n''existe pas';
    END IF;

    -- Vérifier l'année
    IF p_annee IS NULL OR
       p_annee < 1 OR
       p_annee > EXTRACT(YEAR FROM CURRENT_DATE) THEN
        RAISE EXCEPTION 'L''année est invalide';
    END IF;

    -- Vérifier le nombre d'exemplaires
    IF p_nb_exemplaires IS NULL OR p_nb_exemplaires <= 0 THEN
        RAISE EXCEPTION 'Le nombre d''exemplaires doit être supérieur à 0';
    END IF;

    -- Insérer le livre après validation
    INSERT INTO livre(titre, id_auteur, id_categorie, annee, nb_exemplaires)
    VALUES (p_titre, p_id_auteur, p_id_categorie, p_annee, p_nb_exemplaires);

END $$
LANGUAGE PLPGSQL;

/* 1.3 Nombre de livres par catégorie */
CREATE OR REPLACE FUNCTION nb_livres_categorie(p_id_categorie INT)
RETURNS INT AS $$
DECLARE
    n INT;
BEGIN
    -- Vérifier que l'identifiant n'est pas NULL
    IF p_id_categorie IS NULL THEN
        RAISE EXCEPTION 'L''identifiant de la catégorie est obligatoire';
    END IF;

    -- Vérifier que la catégorie existe
    IF NOT EXISTS (
        SELECT 1 FROM categorie
        WHERE id_categorie = p_id_categorie
    ) THEN
        RAISE EXCEPTION 'Cette catégorie n''existe pas';
    END IF;

    -- Compter les livres de la catégorie
    SELECT COUNT(*) INTO n FROM livre
    WHERE id_categorie = p_id_categorie;

    -- Retourner le résultat
    RETURN n;
END $$
LANGUAGE PLPGSQL;



/* =====================================================
   2. FONCTION AVEC BOUCLE
   ===================================================== */
/* 2.1 Fonction avec boucle : maj_annee_livres()
   Parcourir les livres publiés avant 2000 */

CREATE OR REPLACE FUNCTION maj_annee_livres()
RETURNS VOID AS $$
DECLARE
    livre_record RECORD;
BEGIN
    -- Parcourir les livres publiés avant l'année 2000
    FOR livre_record IN
        SELECT titre, annee
        FROM livre
        WHERE annee < 2000
    LOOP
        -- Afficher le titre et l'année de chaque livre
        RAISE NOTICE 'Livre : %, Année : %',
            livre_record.titre,
            livre_record.annee;
    END LOOP;
END $$
LANGUAGE PLPGSQL;


/* =====================================================
   3. FONCTION AVEC CURSEUR EXPLICITE
   ===================================================== */


/* 3.1 Liste des livres d'un auteur */
CREATE OR REPLACE FUNCTION liste_livres_auteur(p_nom_auteur VARCHAR)
RETURNS VOID AS $$
DECLARE
    -- Déclaration du curseur explicite
    curs_livres CURSOR FOR
        SELECT l.titre FROM livre l
        JOIN auteur a ON l.id_auteur = a.id_auteur
        WHERE a.nom = p_nom_auteur;

    -- Variable pour récupérer chaque titre
    v_titre livre.titre%TYPE;

BEGIN
    -- Vérifier le nom de l'auteur
    IF p_nom_auteur IS NULL OR TRIM(p_nom_auteur) = '' THEN
        RAISE EXCEPTION 'Le nom de l''auteur est obligatoire';
    END IF;

    -- Vérifier que l'auteur existe
    IF NOT EXISTS (
        SELECT 1
        FROM auteur
        WHERE nom = p_nom_auteur
    ) THEN
        RAISE EXCEPTION 'Cet auteur n''existe pas';
    END IF;

    -- Ouvrir le curseur
    OPEN curs_livres;

    -- Récupérer le premier livre
    FETCH curs_livres INTO v_titre;

    -- Parcourir les résultats
    WHILE FOUND LOOP

        -- Afficher le titre du livre
        RAISE NOTICE 'Livre : %', v_titre;

        -- Passer au livre suivant
        FETCH curs_livres INTO v_titre;

    END LOOP;

    -- Fermer le curseur
    CLOSE curs_livres;

END $$
LANGUAGE PLPGSQL;

/* =====================================================
   4. SQL DYNAMIQUE
   ===================================================== */
-- Fonction avec SQL dynamique qui compte les éléments d'une table

CREATE OR REPLACE FUNCTION compter_elements(table_name TEXT)
RETURNS INT AS $$
DECLARE
    n INT;
BEGIN
    -- Vérifier le nom de la table
    IF table_name IS NULL OR TRIM(table_name) = '' THEN
        RAISE EXCEPTION 'Le nom de la table est obligatoire';
    END IF;

    -- Construire et exécuter la requete dynamique
    EXECUTE format('SELECT COUNT(*) FROM %I', table_name) INTO n;

    -- retourner le nombre d'enregistrements
    RETURN n;
EXCEPTION WHEN undefined_table THEN
    RAISE EXCEPTION 'La table % n''existe pas', table_name;
END $$
LANGUAGE PLPGSQL; 


/* =====================================================
   5. TRIGGER
   ===================================================== */


/* 5.1 Vérification de disponibilité */

/* =====================================================
   1.7 Fonction trigger : vérifier la disponibilité
   ===================================================== */

CREATE OR REPLACE FUNCTION verif_disponibilite()
RETURNS TRIGGER AS $$
DECLARE
    nb_total INT;
    nb_emprunts INT;
BEGIN
    -- Vérifier uniquement les nouveaux emprunts en cours
    IF NEW.date_retour IS NULL THEN

        -- Récupérer le nombre total d'exemplaires du livre
        SELECT nb_exemplaires
        INTO nb_total
        FROM livre
        WHERE id_livre = NEW.id_livre;

        -- Compter les emprunts actuellement en cours
        SELECT COUNT(*)
        INTO nb_emprunts
        FROM emprunt
        WHERE id_livre = NEW.id_livre
          AND date_retour IS NULL;

        -- Vérifier la disponibilité
        IF nb_total - nb_emprunts <= 0 THEN
            RAISE EXCEPTION
                'Emprunt impossible : aucun exemplaire disponible pour le livre %',
                NEW.id_livre;
        END IF;

    END IF;

    -- Autoriser l'insertion
    RETURN NEW;

END $$
LANGUAGE PLPGSQL;

/* =====================================================
   Création du trigger verif_disponibilite
   ===================================================== */

CREATE OR REPLACE TRIGGER verif_disponibilite
BEFORE INSERT ON emprunt
FOR EACH ROW
EXECUTE PROCEDURE verif_disponibilite();