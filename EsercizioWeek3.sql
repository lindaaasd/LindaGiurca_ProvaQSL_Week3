-- 1. b)
-- 2. Il modo migliore per fare una relazione many to many è creando una Junction Table che contenga le foreign keys
--    collegate alle rispettive tabelle
-- 3. b)
-- 4. b)
-- 5. b) // solo IS NULL & IS NOT NULL

-- È possibile che uno stesso brano faccia parte di più di un Album (ad es. le raccolte contengono brani appartenenti, 
-- in genere, ad album già pubblicati).
-- Una volta realizzato il modello ER entità-relazionale, creare il DB e tutte le tabelle e le relazioni necessarie.
-- Implementare oltre a quelli già esplicitati, anche i seguenti vincoli:
-- - Gli id devono essere auto-incrementati.
-- - Un album deve essere considerato unico sulla base del titolo, anno di uscita, casa
-- discografica, genere e supporto (se uno stesso album viene memorizzato su, ad esempio, due supporti differenti, 
-- i dati relativi a quell’album devono essere registrati separatamente).

create database BandAlbums

create table Band (
    ID_Band int identity (1,1) constraint PK_Band primary key,
    Nome varchar not null,
    NumeroComponenti int not null,
)

create table Brano(
    ID_Brano int identity (1,1) constraint PK_Brano primary key,
    Titolo varchar not null,
    Durata TIME not null,
)

create table Album(
    ID_Album int identity(1,1) constraint PK_Album primary key,
    Titolo varchar not null,
    CasaDiscografica varchar not null,
    Distribuzione varchar not null default 'Unknown' constraint CHK_Distribuzione check 
    ( Distribuzione = 'CD' or Distribuzione = 'Vinile' or Distribuzione = 'Streaming'),
    Genere varchar not null default 'Unknown' constraint CHK_Genere check
    (Genere = 'Classico' or Genere = 'Pop' or Genere = 'Jazz' or Genere = 'Rock' or Genere = 'Metal'),
    ID_Band int not null constraint FK_Band foreign key references Band(ID_Band),
)

create table AlbumBrano(
ID_Brano int not null,
ID_Album int not null,

Constraint FK_Brano foreign key (ID_Brano) references Brano(ID_Brano),
Constraint FK_Album foreign key (ID_Album) references Album(ID_Album),
Constraint PK_AlbumBrano primary key (ID_Brano, ID_Album),
)

alter table Album add constraint AK_AlbumUnico unique (Titolo, CasaDiscografica, Distribuzione, Genere, AnnoUscita)

insert into Band values('The Ramones', 6);
insert into Band values ('The Yeah Yeah Yeahs', 3);
insert into Band values ('Maneskin', 4);
insert into Band values ('883', 2);
insert into Band values ('the Giornalisti', 3);
insert into Band values ('the Beatles', 4);
insert into Band values ('John Lennon ', 1);

insert into Album values ('Imagine', 'Apple', 'Vinile', 'Rock', 7, '09-09-1971');
insert into Album values ('Il ballo della vita', 'Sony Music', 'CD', 'Pop', 3, '10-26-2018');
insert into Album values ('Love', 'Carosello Records', 'Streaming', 'Pop', 5, '09-21-2018');

-- 1) Scrivere una query che restituisca i titoli degli album degli “883” in ordine alfabetico;

insert into Album values ('Nord sud ovest est', 'All music', 'CD', 'Metal', 4, '04-15-1993');
insert into Album values ('La donna il sogno e il grande', 'All music', 'Vinile', 'Metal', 4, '02-15-1995');

select *
from Album
where ID_Band = 4
order by Titolo asc

-- 2) Selezionare tutti gli album della casa discografica “Sony Music” relativi all’anno 2020;

insert into Album values ('Fever to tell', 'Sony Music', 'Vinile', 'Rock', 2, '10-26-2020');

select *
from Album
where CasaDiscografica = 'Sony Music' and YEAR(AnnoUscita) = '2020'

-- 3) Scrivere una query che restituisca tutti i titoli delle canzoni dei “Maneskin” appartenenti
-- ad album pubblicati prima del 2019;

insert into Brano values ('Le parole lontante', '3:24')
insert into AlbumBrano values (1, 3)

select b.Titolo
from AlbumBrano ab join Album a on ab.ID_Album = a.ID_Album
                   join Brano b on ab.ID_Brano = b.ID_Brano
where a.ID_Band = 3 and YEAR(a.AnnoUscita) < '2019'

-- 4) Individuare tutti gli album in cui è contenuta la canzone “Imagine”;

insert into Brano values ('Imagine', '3:03')
insert into AlbumBrano values (3, 1)

select a.Titolo, a.CasaDiscografica, a.Distribuzione
from AlbumBrano ab join Album a on ab.ID_Album = a.ID_Album
                   join Brano b on ab.ID_Brano = b.ID_Brano
where b.Titolo = 'Imagine'

-- 5) Restituire il numero totale di canzoni eseguite dalla band “The Giornalisti”;

insert into Brano values ('New York', '3:40')
insert into Brano values ('Controllo', '4:05')
insert into Brano values ('Love', '3:45')

insert into AlbumBrano values (11, 4)
insert into AlbumBrano values (12, 4)
insert into AlbumBrano values (13, 4)

select COUNT(b.ID_Brano)
from AlbumBrano ab join Album a on ab.ID_Album = a.ID_Album
                   join Brano b on ab.ID_Brano = b.ID_Brano
where a.ID_Band = 5

-- 6) Contare per ogni album, la “durata totale” cioè la somma dei secondi dei suoi brani

select a.ID_Album, SUM(datediff(second, '00:00:00', b.ID_Brano))
from AlbumBrano ab join Album a on ab.ID_Album = a.ID_Album
                   join Brano b on ab.ID_Brano = b.ID_Brano
group by a.ID_Album

-- 7) Mostrare i brani (distinti) degli “883” che durano più di 3 minuti (in alternativa usare i
-- secondi quindi 180 s).

select b.Titolo
from AlbumBrano ab join Album a on ab.ID_Album = a.ID_Album
                   join Brano b on ab.ID_Brano = b.ID_Brano
where a.ID_Band = 4 and b.Durata > '3:00'

-- 8) Mostrare tutte le Band il cui nome inizia per “M” e finisce per “n”.

select Nome
from Band
where Nome LIKE 'M%n'
-- where Nome between 'M' and 'n'

-- 9) Mostrare il titolo dell’Album e di fianco un’etichetta che stabilisce che si tratta di un
-- Album:
-- ‘Very Old’ se il suo anno di uscita è precedente al 1980,
-- ‘New Entry’ se l’anno di uscita è il 2021,
-- ‘Recente’ se il suo anno di uscita è compreso tra il 2010 e 2020, ‘Old’ altrimenti.

select Titolo,
case
when YEAR(AnnoUscita) < '1980' then 'Very Old'
when YEAR(AnnoUscita) between '2010' and '2020'  then 'Old'
when YEAR(AnnoUscita) = '2021' then 'New entry'
else 'Hybrid'
end as [Età di album]
from Album

-- 10) Mostrare i brani non contenuti in nessun album.

insert into Brano values ('I wanna be sedated', '2:32')
insert into Brano values ('Blitzkrieg Bop', '1:56')
insert into Brano values ('Sheena is a punkrocker', '3:10')

select ID_Brano, Titolo
from Brano
where ID_Brano not in (select ID_Brano from AlbumBrano)