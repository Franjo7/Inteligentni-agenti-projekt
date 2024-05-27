# SmartFix DF - Servis za popravke tehničkih uređaja

**SmartFix DF** je servis za popravke raznih tehničkih uređaja kao što su PC, laptopi, mobiteli, printeri, mrežni uređaji te periferni uređaji poput tipkovnica i miševa. Servis raspolaže sa 5 tehničara koji su specijalizirani za određene skupine uređaja. Cilj servisa je optimizirati broj tehničara kako bi se maksimizirala zarada servisa.

---

&nbsp;

## Članovi tima

- Dario Klarić
- Franjo Lovrić

---

&nbsp;

## Sadržaj servisa:

1. **Tehničari i plaće:**
   - Servis raspolaže sa 5 tehničara.
   - Plaća svakog tehničara iznosi 120 KM po satu.
   - Svaki tehničar može popravljati samo određene skupine uređaja.

2. **Vrijeme popravka i zarada:**
   - Prosječno vrijeme potrebno za popravak uređaja je 30 minuta.
   - Cijena popravka ovisi o vrsti kvara:
     - Osnovni popravak: 80 KM
     - Složeni popravak: 120 KM
     - Hitni popravak (izvan radnog vremena): 150 KM

3. **Raspored dolazaka uređaja:**
   - Od 09:00 do 12:00 - 25 uređaja
   - Od 12:00 do 15:00 - 15 uređaja
   - Od 15:00 do 17:00 - 10 uređaja

4. **Model agenta:**
   - Agenti predstavljaju tehničare i uređaje koji dolaze na popravak.
   - Svaki otkucaj vremena simulacije predstavlja jedan minut radnog vremena servisa.

5. **Parametri kontrole:**
   - Broj aktivnih tehničara kontrolira se klizačem (može biti od 0 do 5).
   - Ukoliko uređaj čeka više od 30 minuta nakon pregleda kvara, smatra se da je popravka nemoguća ili neisplativa te uređaj kao agent "umire".

6. **Optimizacija i uspješnost:**
   - Uspješnost odabranog broja radnih mjesta ogleda se u odnosu ukupne zarade servisa (zbroj obavljenih popravaka) i cijene rada angažiranih tehničara.
   - U Excelu se tablično prikazuju dobiveni rezultati te označava optimalno rješenje.
   
---

&nbsp;