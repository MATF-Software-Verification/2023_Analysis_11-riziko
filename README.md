# 2023_Analysis_11-riziko

# :memo: O projektu:
- U okviru ovog rada biće predstavljena analiza projekta ***Riziko*** rađenog u okviru kursa Razvoj softvera na Matematičkom fakultetu, koji se nalazi na [adresi](https://gitlab.com/matf-bg-ac-rs/course-rs/projects-2022-2023/11-riziko) (main grana, hash kod commita: ***ace07a16f23f2dc5aff0ca08b086e33901d716e7***) , gde se u okviru README.md fajla mogu pronaći i detaljnije informacije o samoj igrici, potrebne biblioteke za pokretanje igrice, način pokretanja igrice, autori, kao i link do demo snimka na Youtube. Ovaj rad će sadržati analizu tog projekta, odnosno alate za verifikaciju softvera koji su primenjeni, način njihove primene, rezultate, eventualne pronađene bagove i zaključke izvedene iz ove analize.

- Projekat ***Riziko*** je igrica koja simulira rat i osvajanje tuđih teritorija putem tenkova. Igrice je pravljena za 5 igrača i odvija se naizmeničnim potezima na teritoriji Evrope. Na početku svako od igrača dobija 7 država koje vodi i određen broj tenkova. Pored teritorija i tenkova, svaki igrač dobija i karticu na kojoj piše koji je cilj tog igrača (cilj igrača nije poznat drugim igračima). Igrač koji prvi ispuni cilj sa kartice je pobednik.

# :wrench: Alati koji su korišćeni:

* Valgrind
  * Callgrind
  * Memcheck
* Clang
* Perf
* Flawfinder

# :memo: Zaključak:

Projekat je generalno razumljiv, na momente zna da postane komplikovan i valjalo bi da se uvedu dodatni komentari. Postoji jedan veoma nejasan deo koda koji bi valjalo istražiti zašto je potreban:
![image](https://github.com/MATF-Software-Verification/2023_Analysis_11-riziko/assets/42783584/2a0e13e2-6690-41c1-bfe0-233f6746d06b)

Sa sigurnosne strane treba zameniti zastarelu *Catch* biblioteku sa novom verzijom *Catch2*.
Na nekoliko mesta ima curenje memorije i trebalo bi obratiti pažnju na to. Takođe veliki je broj i događaja koji se dešava što potencijalno može usporiti aplikaciju.
Neke stilske predloge bi trebalo primeniti i postarati se da se ne dešavaju slučajevi da je pokazivač neinicijalizovan a koristi se.
Treba proveriti i konverzije iz šireg *long long* tipa u uži *int* i osigurati se da ne dolazi do potencijalnog baga i neočekivanog rezultata.

Tokom samog testiranja igrice, nije pronađen bag.

# Autor:
Miloš Milaković, 1052/2021
