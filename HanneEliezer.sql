/* Partie 1 du TD */

.mode table 
PRAGMA foreign_keys = ON;
drop table if exists voisins;
drop table if exists departements;
drop table if exists regions;
drop table if exists zus;
drop view if exists voisinsSymNoms;
drop view if exists voisinsSym;
drop view if exists zusCommunePrefecture;

create table regions (
    rid varchar(4) primary key,
    nom varchar(60),
    chef_lieu varchar (60)
);
create table departements (
    code int primary key,
    nom varchar(60) unique,
    prefecture varchar (60),
    rid varchar(4),
    foreign key (rid) references regions 
);
/* question 6 creation table */
/* ici rid1 et rid2 font tous references à regions donc ce sont des clés 
étrangeres  .Cependant on voit bien dans la construction de voisin que 
les associations de rid1 et rid2 ( tuples) sont uniques .Par conséquent
le couple (rid1,rid2) identifie de facon unique la table voisin d'ou ce
 couple constitue une clé primaire composite .En plus de cela , une region
ne doit pas etre voisine d'elle meme ,donc faudra gerer cete contrainte avec 
le check pour eviter ce probleme et etre sur du resultat du count */
create table voisins(
    rid1 varchar(4),
    rid2 varchar(4),
    primary key(rid1,rid2),
    foreign key (rid1) references regions,
    foreign key (rid2) references regions,
    check (rid1 != rid2)
);
/*question 9 pour respecter la contrainte de foreign key pour departement 
qui se refere à nom dans la table  departements , on ajoute la contrainte unique à nom   */
create table zus(
    departement varchar(60) ,
    commune varchar(60),
    quartier varchar(60),
    primary key (departement,commune,quartier),
    foreign key (departement) references departements(nom)
    );


/* import des files csv pour populer */
.separator ','
.import 'regions.csv' regions
.import 'departements.csv'  departements
.import 'voisins.csv' voisins

.separator ';'
.import 'zus.csv' zus 


/* question 2 */
/*
select code , nom 
from departements 
where prefecture = 'Bourges';   */
/* question 3 */
/*
select code ,d.nom as departement ,prefecture ,r.nom as region 
from regions r ,departements d
where r.rid=d.rid 
group by code ;   */
/* question 4 */
/*
select r.nom as region ,chef_lieu , code,d.nom as departement ,prefecture 
from regions r ,departements d
where r.rid=d.rid
order by r.nom asc ;  */
/* question 5 */
/*
select code , d.nom as departement ,prefecture
from regions r ,departements d
where r.rid=d.rid and r.nom='Centre-Val de Loire';  */
/* question 6 */
/*
select count(*) as nombre_total_tuples
from voisins v1 ;  */

/* question 7 
Dans la table , on remarque que les couples de voisins ne sont pas symetriques
(pour chaque tuple (rid1,rid2) il n'y a pas de tuple (rid2,rid1) associés )
*/
/*
create view voisinsSym as 
select rid1, rid2 
from voisins
union
select rid2 ,rid1
from voisins ;
select count(*) as nombre_total_tuples_symetriques
from voisinsSym ;    */
/*le nombre de tuples a doublé (46 tuples) par rapport a la question
precedente (23 tuples) .Ceci est du àl'ajout des tuples symétriques 
dans la vue voisinsSym qui contient maintenant (rid1,rid2) et (rid2,rid1) */
/*
select * from voisinsSym ;
create view voisinsSymNoms as 
select r1.nom as region1 ,r2.nom as region2
from voisinsSym v,regions r1,regions r2 
where r1.rid=v.rid1 and r2.rid=v.rid2;
select * from voisinsSymNoms ;   */

/* question 8 */
/*
select v.region1 ,count(*) as nombre_voisins
from voisinsSymNoms v, regions r 
where r.nom=v.region1 
group by v.region1 
union 
select r1.nom  ,0 as nombre_voisins
from regions r1
where r1.nom not in (select region1 from voisinsSymNoms)
order by count(*) desc;  */

/*question 9
ces données sous forme de page html avec un tableau excell sont brutes .
elles sont pas bien structurées et seront difficiles a manipuler au
 niveau de notre base de dpnnées pour faire des requetes et analyses .
 Il faudra les epurer et ls structurer pour les rendre facilement exploitables .
 */
 /*question 10 
 ce stockage de données est ambigue et non structuré .Cela ne nous facilite pas
l'exploitation des données pour les manipuler .En plus on sait meme pas quels sont
les autres departements auxquels ces quartiers et communes se rattachent encore (associés).
Il faudra sortir et aller voire au niveau de la table departements pour savoir
(requete difficile avec les jointures).on note aussi la violation du principe d'atomicité
(le champ commune doit etre indivisible ).
comment j'aurais fait? j'allais scinder la ligne en 2 l'une avec son departement sa commune
et le meme quartier de memem que l'autre : (Essonne, "Massy", "Le Grand Ensemble")
et (Hauts-de-Seine, "Antony", "Le Grand Ensemble").ceci etant dit , ces cas sont deja peu nombreux 
et en plus cela n'altere en rien le principe d'unicité des tuples (avec notre clé primaire composite)
 tout en repectant l'atomicité  */
 select *
 from zus s
 where commune like '%(%)%';

/*question 11*/
create view zusCommunePrefecture as 
select z.departement , z.commune ,z.quartier 
from zus z ,departements d
where z.departement=d.nom  /* faudra s'assurer que le nom de la commune est dans la prefecture et vice versa pour etre exhaustive*/
    and (z.commune like '%'||d.prefecture||'%' or d.prefecture like '%'||z.commune||'%') ;
select * from zusCommunePrefecture ;
select count(*) as nb_communes_total ,'total'
from zus 
union 
select count(*) as nb_communes_prefecture ,'oui'
from zusCommunePrefecture
where commune in (select commune from zusCommunePrefcture)
union
select count(*) as nb_communes_non_prefecture ,'non'
from zus z
where not exists (
    select *
    from zusCommunePrefecture v
    where v.departement = z.departement  
      and v.commune = z.commune    
      and v.quartier = z.quartier   );

/*question 12*/
select departement ,r.nom as region , count(*) as nombre_zus
from zus z ,regions r ,departements d
where z.departement=d.nom  and d.rid=r.rid
group by departement
union 
select d.nom ,r.nom as region , 0 as nombre_zus
from departements d , regions r
where d.rid=r.rid and d.nom not in (select departement from zus)
order by nombre_zus desc ;

/* question 13 */
select r.nom as region , count(*) as nombre_zus
from regions r,zus z,departements d
where z.departement=d.nom and d.rid=r.rid
group by r.nom
order by nombre_zus desc ;

/*question 14*/
/*version 1*/
select r.nom as region 
from regions r,departements d, zus z
where z.departement=d.nom and d.rid=r.rid 
group by r.nom
having count(distinct d.nom) = (
    select count(*) 
    from departements d2
    where d2.rid = r.rid
);
/*version 2*/
select r.nom 
from regions r
where not exists (
    select * 
    from departements d
    where d.rid = r.rid
    and not exists (
        select * 
        from zus z
        where z.departement = d.nom)
);
