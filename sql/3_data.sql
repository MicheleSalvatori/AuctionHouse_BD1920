INSERT INTO aste.utenti VALUES ("MNTVTR97T57I493M","Vittoria","Mount","1997/12/17","SCAMPITELLA","Via scopigliette,21","SCAMPITELLA", "5386105676692601", "2021/01","Vittoria", "Mount","575", md5("vittoria.mount"), "vittoria.mount",0),
("RVSNZT92T60I089W","Nunziata","Rivas","1992/12/20","San Pietro al Tanagro","Via Roma,13","San Pietro al Tanagro", "4006748400736104", "2023/12","Nunziata", "Rivas","985", md5("nunziata.rivas"), "nunziata.rivas",0),
("ZNGSBN98P28I561G","Sabino","Zinghini","1998/09/28", "Secugnago", "Via Pellicano, 23","SECUGNAGO (LO)","4556268237018208","2024/03","Sabino","Zinghini", "779", md5("sabino.zinghini"), "sabino.zinghini", 0),
("DNGGDE79R21G943W","Egidio","Donegaglia","1979/10/21", "Pove del Grappa", "Via della questura, 2", "Pove del Grappa","4033335645779722","2025/07","Egidio","Donegaglia", "509", md5("egidio.donegaglia"), "egidio.donegaglia", 0),
("SNNSNN96E52F557A","Osanna","Dione","1979/02/02", "Porta Carratica", "Via accorciatoia, 27", "Porta Carratica","4739164956691756","2025/02","Osanna","Dione", "115", md5("osanna.dione"), "osanna.dione", 0),
("DNIDTT79B42G893V","Diletta","Sannullo","1996/05/15", "Alatri", "Via liberta, 13", "Alatri","4001898763036538","2025/11","Diletta","Sannullo", "114", md5("diletta.sannullo"), "diletta.sannullo", 0),
("GNSRFL92B09I022L","Raffaele","Giansetto","1992/02/09", "San Massimo", "Viale ippocrate, 32", "San Massimo","4877916151824546","2025/11","Raffaele","Giansetto", "238", md5("raffaele.giansetto"), "raffaele.giansetto", 0),
("PTRMRZ85E69H447Q","Marzia","Pietrantoni","1985/05/29", "Roccasparvera", "Via cavour, 8", "Roccasparvera","4783771095870920","2025/06","Marzia","Pietrantoni", "625", md5("marzia.pietrantoni"), "marzia.pietrantoni", 0),
("TRMSNT87B64H597L","Santa","Taramasco","1987/02/24", "Rovate", "Via aldo moro, 43", "Rovate","4403900350018921","2025/06","Santa","Taramasco", "531", md5("santa.taramasco"), "santa.taramasco", 0),
("TNTTNT90T31H501Q", "Utente", "Utente", "1990/12/31", "Roma", "Via roma, 1", "Roma", "4757628430437744", "2030/09", "Utente", "Utente", "999", md5("utente.utente"), "utente.utente", 0),
("DMNDMN90T31H501Q", "Admin", "Admin", "1990/12/31", "Roma", "Via roma, 1", "Roma", "4757998430437744", "2029/09", "Admin", "Admin", "999", md5("admin.admin"), "admin.admin", 1),
("SLVMHL98T07A123M", "Michele", "Salvatori", "1998/12/07", "Fumnone", "Via fumone, 1", "Fumone", "4757990030437744", "2029/09", "Michele", "Salvatori", "999", md5("michele.salvatori"), "michele.salvatori", 1);


INSERT INTO aste.categoria VALUES ("Elettrodomestici", 1),("Elettronica", 1),
("Da Cucina", 2),("Audio e Video", 2),("Informatica", 2),("Telefonia e accessori", 2),("Cura della casa", 2),
("Archiviazione", 3),("Grandi", 3),("Piccoli", 3),("Monitor", 3),("Radio", 3),("Smartphone", 3),("Pulizia", 3),
("Smartwatch", 3), ("TV", 3);

INSERT INTO aste.catIndex VALUES
("Elettrodomestici", "Da Cucina"), ("Da Cucina", "Piccoli"), ("Da Cucina", "Grandi"),
("Elettronica", "Audio e video"), ("Elettronica", "Informatica"), ("Elettronica", "Telefonia e accessori"),
("Informatica", "Archiviazione"), ("Informatica", "Monitor"), ("Audio e video", "Radio"), ("Audio e video", "TV"),
("Telefonia e accessori", "Smartphone"), ("Telefonia e accessori", "Smartwatch");

INSERT INTO aste.oggetto VALUES("A01", "Grigio","45x17", "122", "Nuovo", date_add(NOW(), INTERVAL 7 day), "Tostapane", "Piccoli"),
("B45", "Alluminio","230x75x75", "599", "Nuovo", date_add(NOW(), INTERVAL 7 day), "Frigorifero", "Grandi"),
