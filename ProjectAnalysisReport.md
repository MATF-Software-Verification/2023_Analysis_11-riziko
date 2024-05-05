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
