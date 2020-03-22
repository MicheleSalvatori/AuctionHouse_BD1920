INSERT INTO auction_house.utenti VALUES
("DDDMHL98T07A123M", "Michele", "Salvatori", "1998-12-07", "Alatri", "via vicinale cesadoni 28", "03010", "5410640744377561", "2020/01", "Michele", "Salvatori", "981", "pippo", "michele.salvatori");

INSERT INTO auction_house.offerte values
("SLVMHL98T07A123M", DEFAULT, "100", null);

INSERT INTO auction_house.categoria VALUES
("Piccoli", "3");

INSERT INTO auction_house.catIndex VALUES
("Cucina", "Grandi");


delete from auction_house.utenti where CF_Utente = "SLVMHL98T07A123M";
delete from auction_house.offerte where CF_Utente = "SLVMHL98T07A123M" and datatime_stamp <= now();

ALTER TABLE auction_house.categoria ADD  PRIMARY KEY;
ALTER TABLE auction_house.offerte drop foreign key offerte_ibfk_1;
ALTER TABLE auction_house.offerte ADD CONSTRAINT offerte_ibfk_1 FOREIGN KEY (CF_Utente) REFERENCES auction_house.utenti(CF_Utente) ON DELETE CASCADE ON UPDATE CASCADE;



select * from auction_house.offerte;
select * from auction_house.categoria;
select * from auction_house.catIndex;
select * from auction_house.utenti;



insert into auction_house.prova values(CURDATE(), now);