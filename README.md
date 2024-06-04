# SmartFix DF - Servis za popravke tehničkih uređaja

_**SmartFix DF**_ je servis za popravke raznih tehničkih uređaja kao što su PC, laptopi, mobiteli, printeri, mrežni uređaji te periferni uređaji poput tipkovnica i miševa. Servis raspolaže sa 5 tehničara koji su specijalizirani za određene skupine uređaja. Cilj servisa je optimizirati broj tehničara kako bi se maksimizirala zarada servisa.

---

&nbsp;

## Članovi tima

- **_Dario Klarić_**
- **_Franjo Lovrić_**

---

&nbsp;

## Instalacija

>### Kloniranje projekta:

```
 git clone https://github.com/Franjo7/Inteligentni-agenti-projekt.git
```

>### Pokretanje projekta:

Pokretanje projekta sa [__NetLogo__](https://ccl.northwestern.edu/netlogo/download.shtml)

---

&nbsp;

## Sadržaj

1. Opis rada servisa
   - Tehničari i plaće 
   - Vrijeme popravka i zarada
   - Raspored dolazaka i uređaja
   - Model agenta
   - Parametri kontrole
   - Optimizacija i uspješnost
   - Dodatno

2. Pregled simulacijskog okruženja
3. Zaključak
     
---

&nbsp;

## Opis rada servisa

>### **1. Tehničari i plaće:**
   - Servis raspolaže sa **5 tehničara**
   - Plaća svakog tehničara iznosi **120 KM po satu**
   - Svaki tehničar može popravljati samo **određene skupine uređaja**

>### **2. Vrijeme popravka i zarada:**
   - Prosječno vrijeme potrebno za popravak uređaja je **30 minuta _(30 ticks)_**
   - Cijena popravka ovisi o vrsti kvara:
     - Osnovni popravak → **80 KM**
     - Složeni popravak → **120 KM**
     - Hitni popravak → **150 KM**

>### **3. Raspored dolazaka uređaja:**
   - Od 09:00 do 12:00 → **25 uređaja**
   - Od 12:00 do 15:00 → **15 uređaja**
   - Od 15:00 do 17:00 → **10 uređaja**

>### **4. Model agenta:**
   - Agenti predstavljaju **tehničare** i **uređaje** koji dolaze na popravak
   - Svaki otkucaj vremena simulacije predstavlja **jedan minut** radnog vremena servisa

>### **5. Parametri kontrole:**
   - Broj aktivnih tehničara kontrolira se klizačem (može biti od **0 do 5**)
   - Ukoliko uređaj čeka **više od 30 minuta** nakon pregleda kvara, smatra se da je popravka nemoguća ili neisplativa te uređaj kao agent "umire"

>### **6. Optimizacija i uspješnost:**
   - Uspješnost odabranog broja radnih mjesta ogleda se u odnosu **ukupne zarade** servisa (zbroj obavljenih popravaka) i **cijene rada** angažiranih tehničara
   - U Excelu se tablično prikazuju dobiveni rezultati koji označavaju **optimalno rješenje**

>### **7. Dodatno:**
- Realiziran je simulacijski model u kojem pojedini tehničari mogu popravljati samo **određene skupine uređaja**
  
---

&nbsp;

## Pregled simulacijskog okruženja

![Simulacijsko okruženje](https://github.com/Franjo7/Inteligentni-agenti-projekt/assets/94640801/2546db3e-e2e0-4075-bffd-0cbeef337b4a)

---

&nbsp;

## Zaključak

Provedena simulacija pružila je dubinsku analizu učinkovitosti tehničara unutar servisnog okruženja, omogućujući pregled ključnih parametara kao što su zarada, troškovi te broj uspješnih i neuspješnih popravaka. Rezultati simulacije ukazuju na kritične točke u radnom procesu koje mogu biti optimizirane za poboljšanje cjelokupne učinkovitosti servisa. Prikupljeni podaci mogu poslužiti kao osnova za donošenje odluka o raspodjeli resursa, planiranju radnog vremena i strategijama za povećanje profitabilnosti. Ovaj pristup omogućuje bolju prilagodbu poslovanja prema dinamičnim zahtjevima tržišta, te poboljšava zadovoljstvo korisnika.

---

&nbsp;

© Inteligentni agenti (NetLogo) 2024.