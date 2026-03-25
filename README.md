# Market App

Market App je Flutter mobilna aplikacija koja omogućava korisnicima objavljivanje, pretragu i kupovinu artikala. Aplikacija je razvijena kao dio praktičnog zadatka sa fokusom na modernu arhitekturu i rad sa Firebase servisima.

---

## Opis aplikacije

Aplikacija simulira online marketplace gdje korisnici mogu:

- pregledati artikle bez prijave  
- registrovati se i prijaviti  
- objavljivati artikle  
- pretraživati artikle i korisnike  
- upravljati vlastitim profilom  

Cilj aplikacije je demonstracija kompletnog razvoja mobilne aplikacije koristeći savremene Flutter tehnologije i arhitekturne principe.

---

## Funkcionalnosti

### Autentifikacija
- login i registracija (email/password i Google)  
- mogućnost korištenja aplikacije bez prijave (ograničene funkcije)  

### Profil korisnika
- pregled i uređivanje ličnih podataka  
- dodavanje profilne slike  
- prikaz ocjena i dojmova  

### Artikli
- objavljivanje artikala sa slikama i detaljima  
- editovanje i brisanje (soft delete)  

### Pretraga i listanje
- pregled svih dostupnih artikala  

---

##  Tehnologije

- Flutter  
- Dart  
- BloC 
- flutter_hooks (local state)  
- Firebase (Auth, Firestore, Storage, Cloud Functions)  
- go_router (navigacija)  
- get_it & injectable (dependency injection)  
- dart_mappable (modeli i JSON mapiranje)  

---

## Arhitektura

Aplikacija koristi modernu **feature-first strukturu** sa slojevima:

- Presentation (UI)  
- Bloc / Cubit (state management)  
- Domain (modeli i logika)  
- Data (repositories i data sources)  

Ovakav pristup omogućava skalabilnost, održivost i jasnu organizaciju koda.

---

Slike aplikacije:

<img width="232" height="502" alt="Screenshot 2026-03-06 223349" src="https://github.com/user-attachments/assets/db65c25b-4189-4114-8a39-8af55b306b57" />

<img width="226" height="492" alt="Screenshot 2026-03-06 223723" src="https://github.com/user-attachments/assets/032437ee-8bbd-4b9f-897c-be419b4cab84" />

<img width="227" height="490" alt="Screenshot 2026-03-06 223938" src="https://github.com/user-attachments/assets/07ec285e-50af-4de2-bfd3-870a1e7a3b14" />

<img width="229" height="491" alt="Screenshot 2026-03-06 223811" src="https://github.com/user-attachments/assets/406f4941-38e6-456d-aa71-40db6dde72af" />
