- proteomics: studio di tutte le proteine prodotte o modificate da un organismo, sistema biologico o cellula in un determinato momento
- REACTOME: Neo4j, graph database, Cypher
- REACTOME: [MySQL dump](https://reactome.org/download-data)
- [REACTOM BNs](https://reactome.org/docs/training/ReactomeFIVizapp.pdf#:~:text=The%20main%20features%20of%20the%20plug%2Din%20are,edge%20in%20the%20the%20network%20view%20panel.&text=The%20main%20features%20of%20the%20plug%2Din%20are,edge%20in%20the%20the%20network%20view%20panel.)
- BIOMARCATORE ONCOLOGICO: un qualche tipo di sostanza che può essere rilevata ed è associata alla presenza / crescita di un tumore 
- MENSTRUAL BLEEDING: excessively havey flow, abnormal bleeding
- PATHWAY ENDOCRINOLOGICO: si riferisce al sistema di comunicazione e regolazione all'interno del corpo che coinvolge gli ormoni, messaggeri chimici prodotti dalle ghiandole endocrine. Questi ormoni viaggiano nel sangue verso le cellule bersaglio, dove interagiscono con recettori specifici per influenzare le funzioni cellulari
- NEFROLOGICO: è la branca della medicina che si occupa dello studio, della diagnosi e del trattamento delle malattie dei reni e delle vie urinarie
- ONCOLOGICO: si riferisce a tutto ciò che è relativo ai tumori, sia benigni che maligni, e alla branca della medicina che li studia, l'oncologia

Proposta di punto di caduta:

Mostriamo 
1) un algoritmo che decompone una large boolean network in componenti lascamente connesse
2) mostriamo che l'insieme degli attrattori della large network può essere calcolato come unione deggli attratori calcolati sulle componenti.

Avanzamento rispetto alla staot dell'arte:

1) L'algoritmo nel apper che vi ho mandato decompone in SCC, ma quello che proponiamo noi vale anche per networks fortemente connesses, come è il caso per la maggior parte del grafo di REACTOME
2) l'algoritmo nel apper gestisce reti con poche centinaia di nodi, noi possiamo gestire reti con migliaia di noi.
# What question is the model supposed to answer?
# Is it built to explain a surprising observation?
# Is it built to relate separate observations with each other and with previous knowledge?
# Is it built to make predictions, for example, about the effect of specific perturbations?


medicina, seri di dati + triage (allarme (verde, giallo, rosso pericolo), anticipare avventi avversi (decesso)
- data driven

costruire uno stimatore, trend su serie temporali (rispetto ad altri o lui stesso)
- letteratura scientifica 
- valori medi
- organizzare dati + base di dati
- machine learning + un minimo explainable
- purining + stabilizzazione

partendo dai modelli
- pathway qualitativi (repository)
- reti booleane (attiva o desittavia)
    - poco / parecchi espressa
    - approcci sincroni 
    - approcci asincroni (passi diversi)

    - ci si mette nel contiuo, sistema di equazioni differenziali
    - scegliere parametri che regolano la velocità
    - questo

    - trovare i parametri
    - proteomics (valori medi proteine)
    - parametri consistenti
    - tutti i pathway neal reattome (10k nodi)
    - simulabile

    - i geni comandano tutti (ROM)
    - distanza uno dai geni (grafo diretto)
    ... distanza n - 1, n ...
        - fortemente connesso
    - cerco un taglio minimizzando il feedback
    - ho isolato il controllore
    - gerarchia sulle velocità (chi comanda è più veloce)
    - reactome (fornisce db)
    - neuroj
    - volto a capire quali sono i moduli
    - moduli "più liberali"

    - ci sono paper che l'hanno fatto (concetto di controllo)
        - si conservano gli attrattori

    - biomarcatori oncologici
    - root cause (ipotesi di diagnosi) (gene serpine, menstrual bleeding non abbastanza espresso)

cyberphisical
    - idra
    - dato un sistema blackbox, simulare
    - determinare il controllore (reinforcement learning)
        - ma con garanzie (+ formal verification usando statistical model checking)
        - sequenze avversarie, pesco, liele do, se resiste va bene
        - identificare l'algoritmo giusto di learning (quelli visti a lezione non assistono)
        - algoritmo basato su black-box opt (OpenAI) che si presta allo satistical model checking
        - aspetto computazionale (ottimizzazione)
        - parte computazionale statistical model checking
    - dare l'algoritmo e incarnarlo (multiagent idra)
    - io ho il mio sistema + voglio fare il controllore + distrurbi, ma non ne conosco la distribuzione, + cambia
    - online learning
    - non posso fare esperimenti (posso farmi un modello)
    - se non è stazionario devo essere capace di apprendere mentre eseguo
    - non ci devo ammettere troppo
    - apprendere derivate
    - ho un avversario
        - drone che scappa dal nemico
        - pursuer evader
        - verifica automatica del software
        - statistical model checking + orizzzonte
            - controesempio la cui descrizione è complessa al più un tot?
            - complessità di kormogorov checking
            - quand'è che una stringa è random? Non c'è una macchina d iTuring più piccola che la discrive
            - i controesempi non sono random
            - questa cosa non è mai stata sfruttata (è nota)
            - il controesempio sfrutta i bug

- siade (più operativo)
- più investigativo? QA? CPlex + support vector machine (SVM)
- identificando un pathway indecrinologico + aggredendo il DB
- MILP, guardo il grafone, delego al MILP le considerazioni
- cerca taglio che massimizza una tale
- dichiarare bene il problema

- paper
- chatgpt
- roba web

- paper d'ispirazione (immaginiamo di avere il grafone, e formuliamo il problema)
- scarichiamo il grafone di reactome MySQL

step 1.

- obiettivo splittare controllore e controllati
- feedback al contrario minimizzato (su tutto il controllore e tutto il controllato)
- queste due parti deve avere più o meno la stessa (o controllore più piccolo)
- discorso euristico
- prodotto più vicino
    - divite et impera per gli attrattori
    - sui pathway si può scoprire qualcosa per compolenti (pathway sono piccoli, 20, 40)

step 2.
- fare il gioco sui pathway
- punto di caduta
- endicronologia: americani + europeo
- cross talk fra pathway
- visione d'insieme 
- punto di caduta a breve termine

... 
    - dividendo in compolnenti piccole posso simulare le compoenti piccole da sole
    - generica componente piccola: parte forward (verso il comandato, actuation)
    - parte backward (il sensing)
    - far vedere che fare cose su tanti piccoli è meglio che farli su tanti grandi
    - sensing ha un certo valor medio, forma a paicere, e mi da luogo all'attuazione
    - calcolare possibili valori per costanti cinetiche delle singole parti
    - stesso meccanimo assegno le costanti a tutto
    - valori medi conosciuti dalla letteratura
    - spacchettamento orientato a usare meglio i dati disponibili
    - funzioni liberari intorno al singolo componente

piccolo problema + si espande
FC
- dialisi
- + oncologiche
- endrocrinologiche
- nefrologiche

== 24 giugno alle 17:00
