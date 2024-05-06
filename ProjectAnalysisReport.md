# Izveštaj analize projekta

## 1. Valgrind
**Valgrind** je profajler otvorenog koda koji, uz pomoć alata koji se prave za njega, dinamički analizira korisnički program. Ovaj program može da detektuje mnogo problema prilikom rada sa memorijom. Neki od najpoznatijih alata koje sadrži Valgrind su:

* **Memcheck** - koristi se za detektovanje memorijskih grešaka
* **Massif** - koristi se za praćenje rada dinamičke memorije
* **Callgrind** - koristi se da generiše listu poziva funkcija korisničkog programa u vidu grafa
* **Cachegrind** - koristi se za softversko profajliranje keš memorije mašine na kojoj se program izvršava
* **Hellgrind** i **DRD** - koriste se za detektovanje grešaka niti

Svaki od ovih alata zahteva da na računaru prethodno postoji instaliran Valgrind:
```
sudo apt-get install valgrind
```

### 1.1. Memcheck
**Memcheck** je najpoznatiji alat Valgrind-a. Njegova najveća prednost je što vrši analizu mašinskog koda a ne izvornog, pa samim tim može da analizira program pisan u bilo kom jeziku. Neke od grešaka koje može da detektuju su:

* Upisivanje podataka van opsega hipa i steka
* Pristupanje memoriji koja je već oslobođena
* Neispravno oslobađanje hip memorije - duplo oslobađanje hip blokova ili neupareno korišćenje funkcija za alociranje i dealociranje memorije
* Curenje memorije
* Korišćenje vrednosti koje nisu inicijalizovane
* Preklapanje parametara koji su prosleđeni funkcijama - dva pokazivača pokazuju na isti blok memorije kod funkcije *memcpy*

Da bi alat Memcheck mogao da se pokrene pre toga je projekat **potrebno** kompajlirati u *debug* režimu. U slučaju da je kompajliran u *release* režimu, izvršiće se određene optimizacije i potencijalno nećemo moći da pronađemo sve greške.

U okviru ovog projekta dodata je skripta [*run_memcheck.sh*](https://github.com/MATF-Software-Verification/2023_Analysis_11-riziko/blob/main/Valgrind/Memcheck/run_memcheck.sh) u kojoj se nalazi i komanda za pokretanje ovog alata.

Ono što je specificno za Memcheck je da ne mora da se navodi dodatna opcija da se specifikuje alat koji će se pokrenuti nego će Valgrind podrazumevano pokrenuti Memcheck.

Neke od opcija koje su navedene u okviru komande za pokretanje Memcheck-a:
* *--show-leak-kinds=all* - za prikaz svih vrsta curenja memorije u programu
* *--leak-check=full* - dobijaju se detalji za svaki definitivno izgubljen ili eventualno izgubljen blok, uključujući i mesto alociranja tog bloka
* *--track-origins=yes* - opcija koja nam dodatno pomaže da pronađemo deo koda gde je nastala greška
* *--log-file="memcheck_analysis.txt"* - putanja do fajla u kom će se sačuvati izveštaj rada alata

Rezultat rada ovog alata se nalazi u okviru fajla [*memcheck_analysis.txt*](https://github.com/MATF-Software-Verification/2023_Analysis_11-riziko/blob/main/Valgrind/Memcheck/memcheck_analysis.txt).

***Zaključak na osnovu izveštaja alata Memcheck:***

Na kraju izveštaja može se naći sažetak izvršavanja alata.
<pre>
==1869== LEAK SUMMARY:
==1869==    definitely lost: 1,329 bytes in 43 blocks
==1869==    indirectly lost: 864 bytes in 10 blocks
==1869==      possibly lost: 3,840 bytes in 33 blocks
==1869==    still reachable: 3,218,016 bytes in 28,656 blocks
==1869==                       of which reachable via heuristic:
==1869==                         length64           : 4,960 bytes in 82 blocks
==1869==                         newarray           : 2,096 bytes in 51 blocks
==1869==         suppressed: 0 bytes in 0 blocks
</pre>

Može se primetiti da ima velika količina memorije koja nije oslobođena na adekvatan način, uglavom tu memoriju alociraju različite Qt funkcije ali postoji i primer gde memoriju nije alocirala Qt funkcija:
<pre>
==1869== 1 bytes in 1 blocks are definitely lost in loss record 5 of 8,770
==1869==    at 0x483BE63: operator new(unsigned long) (in /usr/lib/x86_64-linux-gnu/valgrind/vgpreload_memcheck-amd64-linux.so)
==1869==    by 0x11CCC2: MainWindow::MainWindow(QWidget*) (mainwindow.cpp:32)
==1869==    by 0x11CA75: main (main.cpp:8)
</pre>

U ovom slučaju na kraju funkcije fali pozivanje operatora *delete*. Ova situacija se mogla izbeći i korišćenjem pametnog pokazivača ***unique_ptr***, na taj način na kraju funkcije bi se memorija automatski oslobodila. Dodatno, može se koristiti i pametni pokazivač ***shared_ptr***, ako je potrebno da više objekata imaju pokazivač na istu memoriju, kada se unište svi pokazivači, automatski će se osloboditi i taj blok memorije.

Iako u klasama postoje destruktori, oni su uglavnom podrazumevani (sem u klasi *Game.cpp* i *MainWindow.cpp*). Jedno od unapređenja je bolje korišćenje samih destruktora i oslobađanje memorije u okviru njih.

### 1.2. Callgrind
**Callgrind** je alat koji generiše listu poziva funkcija korisničkog programa u vidu grafa. U osnovnim podešavanjima sakupljeni podaci se sastoje od:
* Broja izvršenih instrukcija
* Njihov odnos sa linijom u izvršnom kodu
* Odnos pozivaoc/pozvann između funkcija
* Broj poziva funkcija

Pored toga, uz navođenje dodatnih opcija, ovaj alat može da vrši i analizu upotrebe keš memorije i profajliranje grana programa, pa samim tim ovaj alat predstavlja proširenje alata **Cachegrind**.
  
Da bi alat Callgrind mogao da se pokrene pre toga je projekat **potrebno** kompajlirati u *profile* režimu. Potrebno je da se kompajlira u ovom režimu da bi se izvršile dodatne optimizacije i da bi zapravo softver bio u stanju koje je slično onom za produkciju. Glavna razlika u odnosu na *release* režim je taj što u ovom režimu postoje dodatne debug informacije.

U okviru ovog projekta dodata je skripta [*run_callgrind.sh*](https://github.com/MATF-Software-Verification/2023_Analysis_11-riziko/blob/main/Valgrind/Callgrind/run_callgrind.sh) u kojoj se nalazi i komanda za pokretanje ovog alata.

U okviru fajl [callgrind.out.25584](https://github.com/MATF-Software-Verification/2023_Analysis_11-riziko/blob/main/Valgrind/Callgrind/callgrind.out.25584) se nalazi rezultat rada alata Callgrind. Ovakav izveštaj nije čitljiv pa za njegovo razumevanje se koristi alat **KCachegrind**, koji pruža grafičku reprezentaciju podataka.

Na sledećoj slici može da se vidi izgled izveštaja u okviru alata **KCachegrind**:
![callgrind_visual.png](https://github.com/MATF-Software-Verification/2023_Analysis_11-riziko/blob/main/Valgrind/Callgrind/callgrind_visual.png)

Sa leve strane možemo da vidimo koliko puta je koja funkcija pozvana kao i broj izvršenih funkcija:
![callgrind_number_of_calls.png](https://github.com/MATF-Software-Verification/2023_Analysis_11-riziko/blob/main/Valgrind/Callgrind/callgrind_number_of_calls.png)

Ako kliknemo na neko funkciju sa desne strane nam se otvaraju dodatni podaci o izvršavanju date funkcije gde možemo da vidimo i koliko puta je koja funkcija pozvala odabranu funkciju:
![callgrind_all_callers.png](https://github.com/MATF-Software-Verification/2023_Analysis_11-riziko/blob/main/Valgrind/Callgrind/callgrind_all_callers.png)

***Zaključak na osnovu izveštaja alata Callgrind***

U okviru izveštaja nije primećen veliki broj poziva funkcija koju su implementirali autori projekta. Najviše je poziva Qt funkcija na koje je veoma teško uticati.


## 2. Clang
**Clang** je kompajler otvorenog koda za C familiju programskih jezika. Koristi LLVM optimizator i generator koda.


### 2.1. Clang-tidy
**Clang-tidy** statički analizator koda koji je zasnovan na Clang-u. Njegova uloga je da pomogne u prepoznavanju različiih programerskih grešaka kao što su kršenje stila pisanja, pogrešno korišćenje interfejsa ili da prepozna određene bagove koje je moguće pronaći bez prevođenja izvornog koda.

U okviru ovog projekta **Clang-tidy** je korišćen kao deo QtCreator-a.
Da bi se pristupilo ovom analizatoru potrebno je kliknuti na tab *Analyze* i odabrati opciju *Clang-tidy*:

![choose_clang_tidy.png](https://github.com/MATF-Software-Verification/2023_Analysis_11-riziko/blob/main/Clang/Clang-Tidy/choose_clang_tidy.png)

Nakon toga, otvoriće se prozor u okviru kog možemo da biramo fajlove koje želimo da analiziramo:

![choose_files_to_analyze.png](https://github.com/MATF-Software-Verification/2023_Analysis_11-riziko/blob/main/Clang/Clang-Tidy/choose_files_to_analyze.png)

Klikom na dugme *Analyze* pokrenuće se analiza fajlova:

![analysis_in_progress.png](https://github.com/MATF-Software-Verification/2023_Analysis_11-riziko/blob/main/Clang/Clang-Tidy/analysis_in_progress.png)

Dobija se sledeći rezultat:

![clang_tidy_results.png](https://github.com/MATF-Software-Verification/2023_Analysis_11-riziko/blob/main/Clang/Clang-Tidy/clang_tidy_results.png)

Klikom na neko od izbačenih upozorenja možemo da vidimo korake pod kojim može da dođe do slučaja na koji nas *Clang-tidy* upozorava:

![clang_tidy_steps.png](https://github.com/MATF-Software-Verification/2023_Analysis_11-riziko/blob/main/Clang/Clang-Tidy/clang_tidy_steps.png)

Ovim smo dobili rezultate kada smo pokrenuli Clang-tidy u podrazumevanoj konfiguraciji (*clang* provera je uključena), dodatno možemo da dodamo i našu konfiguraciju. Potrebno je kliknuti na tab *Edit* i odabrati opciju *Preferences* iz padajućeg menija. Nakon što to kliknemo pronađemo sledeći meni:

![choose_custom_configuration.png](https://github.com/MATF-Software-Verification/2023_Analysis_11-riziko/blob/main/Clang/Clang-Tidy/choose_custom_configuration.png)

Otvoriće se sledeći prozor gde možemo za **Clang-tidy** (isto važi i za *Clazy*) odaberemo različite provere koje želimo da izvrši.

![specify_configuration.png](https://github.com/MATF-Software-Verification/2023_Analysis_11-riziko/blob/main/Clang/Clang-Tidy/specify_configuration.png)

U slučaju da odaberemo *bugprone* proveru, koja nam govori potencijalna mesta u kodu gde mogu da nastanu bagovi, dobićemo sledeće rezultate:

![bugprone_configuration.png](https://github.com/MATF-Software-Verification/2023_Analysis_11-riziko/blob/main/Clang/Clang-Tidy/bugprone_configuration.png)

A ako odaberemo *readibility* proveru, koja nam govori mesta gde možemo dodatno unaprediti kod da bude razumljiviji, dobićemo sledeće rezultate:

![readability_configuration.png](https://github.com/MATF-Software-Verification/2023_Analysis_11-riziko/blob/main/Clang/Clang-Tidy/readability_configuration.png)

***Zaključak na osnovu izveštaja alata Clang-tidy***

U zavisnosti od konfiguracije dobili smo različita upozorenja.

Za proveru *readaibility*:
* Treba uvesti konstante umesto magičnih brojeva
* Imena varijabli i parametara koji su prekratki treba promeniti tako da budu duži
* Određene metode u okviru klasa mogu da budu statičke
* Određene redundantne izraze treba izbaciti
* Ne treba koristiti *else* nakon naredbe *return* u okviru prethodnog *if* grananja

Za proveru *bugprone*:
* Dobijamo upozorenja da proverimo konverzije iz šireg tipa u uži tip - *long long* u projektu se konvertuje u *int*
* U jednoj od funkcija imamo susedne parametre koji su slično imenovani pa slučajno mogu da se zamene

Za osnovnu, *clang* proveru:
* Izbaciti promenljive koje se nikada ne koriste
* Proveriti i osigurati se da ne mogu da se dese slučajevi da je neki od pokazivača neinicijalizovan


### 2.1. Clazy
**Clazy** je alat koji pomaže Clang-u da razume semantiku Qt-a. Prikazuje upozorenja koja su povezana sa Qt-em koja mogu biti od nepotrebne alokacije memorije do toga da se API pogrešno koristi. Dodatno, može da prikaže akcije koje su potrebne da se srede neki od problema.

U okviru ovog projekta **Clazy** je korišćen kao deo QtCreator-a.
Slično kao i kod *Clang-tidy*, da bi se pristupilo ovom analizatoru potrebno je kliknuti na tab *Analyze* i odabrati opciju *Clazy*.
Isto se biraju fajlovi koje želimo da analiziramo.
Takođe, postoje dodatne konfiguracije i *Clazy* alata u zavisnosti od toga koliko potencijalno lažnih upozorenja želimo.
Na sledećoj slici su prikazani rezultati koji su dobijeni pod osnovnom konfiguracijom (ova konfiguracija uključuje nivo 0 - bez lažnih upozorenja, i nivo 1 - veoma malo lažnih upozorenja):

![clazy_results.png](https://github.com/MATF-Software-Verification/2023_Analysis_11-riziko/blob/main/Clang/Clazy/clazy_results.png)

***Zaključak na osnovu izveštaja alata Clazy***

Skoro sva upozorenja su vezana za imenovanje *slotova*. Koriste stari pristup, odnosno da ime slota počinje sa *on_*. Ovaj način podrazumeva da su automatski slotovi povezani sa odgovarajućim signalom, ali ovaj pristup je loš jer da se promeni ime signala ili slota, taj signal i slot više neće biti povezani. Bolje je eksplicitno povezati signal i slot uz naredbu *connect*.

Drugo upozorenje koje se javlja je da *Q_PROPERTY* treba da bude *CONSTANT* ili *NOTIFY*. *Q_PROPERTY* se uglavnom koristi za povezivanje varijable sa geterom i seterom kao i slanje signala. Prednost korišćenja *Q_PROPERTY* je to što se takvim varijablama može pristupiti u okviru QML-a. U konkretnim slučajevima, ne može da bude konstantna vrednost zato što postoji i seter i samim tim vrednost varijable može da se promeni. *Notify* je opcioni deo i s obzirom da ne treba da se šalje nigde signal ovaj deo može da se izostavi. Samim tim, ova upozorenja mogu da se ignorišu.
