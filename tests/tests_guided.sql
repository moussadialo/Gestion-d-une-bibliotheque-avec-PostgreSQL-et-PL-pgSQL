-- Test de la fonction ajouter_auteur
SELECT ajouter_auteur('George Orwell', 'Royaume-Uni');
select * from auteur where nom = 'George Orwell';

-- Test de la fonction ajouter_livre 
-- cas valide avec 3 exemplaire
/* =========================================
   TESTS : ajouter_livre()
   ========================================= */

-- Cas valide
SELECT ajouter_livre('1984', 1, 1, 1949, 3);

-- Titre vide : erreur attendue
SELECT ajouter_livre('', 1, 1, 1949, 3);

-- Auteur inexistant : erreur attendue
SELECT ajouter_livre('Livre test', 999, 1, 1949, 3);

-- Catégorie inexistante : erreur attendue
SELECT ajouter_livre('Livre test', 1, 999, 1949, 3);

-- Année NULL : erreur attendue
SELECT ajouter_livre('Livre test', 1, 1, NULL, 3);

-- Nombre d'exemplaires nul : erreur attendue
SELECT ajouter_livre('Livre test', 1, 1, 1949, 0);


/* =========================================
   TESTS : nb_livres_categorie()
   ========================================= */

-- Catégorie existante
SELECT nb_livres_categorie(1);

-- Catégorie inexistante : erreur attendue
SELECT nb_livres_categorie(999);

-- Identifiant NULL : erreur attendue
SELECT nb_livres_categorie(NULL); -- Erreur


--TEST : maj_annee_livres()
SELECT maj_annee_livres();


/* =====================================================
   TESTS : liste_livres_auteur()
   ===================================================== */

-- Auteur existant avec plusieurs livres
SELECT liste_livres_auteur('Victor Hugo');

-- Auteur existant avec un seul livre
SELECT liste_livres_auteur('Isaac Asimov');

-- Auteur inexistant : exception attendue
SELECT liste_livres_auteur('Auteur Inconnu');

-- Nom NULL : exception attendue
SELECT liste_livres_auteur(NULL);


/* =====================================================
   TESTS : compter_elements()
   ===================================================== */

-- Compter les auteurs
SELECT compter_elements('auteur');

-- Compter les livres
SELECT compter_elements('livre');

-- Compter les emprunteurs
SELECT compter_elements('emprunteur');

-- Table inexistante : exception attendue
SELECT compter_elements('table_inconnue');

-- Paramètre NULL : exception attendue
SELECT compter_elements(NULL);

/* =====================================================
   TESTS : verif_disponibilite
   ===================================================== */

-- Cas 1 : Fondation
-- 2 exemplaires et 2 emprunts en cours.
-- L'insertion doit être refusée.

INSERT INTO emprunt(id_livre, id_emprunteur, date_emprunt, date_retour)
VALUES (3, 3, CURRENT_DATE, NULL);


-- Cas 2 : Les Misérables
-- 3 exemplaires et 1 emprunt en cours.
-- L'insertion doit être autorisée.

INSERT INTO emprunt(id_livre, id_emprunteur, date_emprunt, date_retour)
VALUES (1, 2, CURRENT_DATE, NULL);


-- Vérifier les emprunts du livre 1

SELECT *
FROM emprunt
WHERE id_livre = 1;