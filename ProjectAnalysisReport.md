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
