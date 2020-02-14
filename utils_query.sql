INSERT INTO auction_house.utenti VALUES
("SLVMHL98T07A123M", "Piero", "Salvatori", "1998-12-07", "Alatri", "via vicinale cesadoni 28", "03010", "5410640744377561", "2024-01-01", "Michele", "Salvatori", "981", "pippo");

delete from auction_house.utenti where CF_Utente = "SLVCHL98T07A123M";

ALTER TABLE auction_house.utenti modify numero_carta varchar(16);

select * from auction_house.utenti ;

update auction_house.utenti set numero_carta = "5410640744377561" where CF_Utente = "SLVMHL98T07A123M";

INSERT INTO auction_house.offerte values
("SLVMHL98T07A123M", current_timestamp, "100", "15");

select * from auction_house.offerte;
select * from auction_house.categoria;
select * from auction_house.catIndex;

INSERT INTO auction_house.categoria VALUES
("Piccoli", "3");

INSERT INTO auction_house.catIndex VALUES
("Cucina", "Grandi");

