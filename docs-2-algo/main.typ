#set page(margin: (y: .5in))
#set text(font: "New Computer Modern", lang: "it", weight: "light", size: 11pt)
#show image: set text(font: "LMMono10", size: 10.5pt, weight: 900)

#image("./legend.svg", width: 40%)
#figure(caption: [`SET1` è ordinato, `SET2` NON è ordinato])[
    #image("./example-3.svg")
]

*NOTA:* è fondamentale notare che nonostante `SET2` NON sia ordinato, i membri
hanno comunque un "ordine" associato (sull'arco `member` compare un numero con
l'ordine).

Riporto l'entry nella documentazione:

_"Sets may be ordered or unordered as specified in the `isOrdered` attribute. A
specific member of an ordered set has a correspondence with a specific member of
another ordered set, as specified by their positions within the sets. For
example, consider an ordered set containing substrate1 and substrate2 that
reacts to yield an ordered set containing product1 and product2. In this case,
substrate1 will yield only product1 and substrate2 will yield only product2. In
the case of unordered sets, any member in an input set can correspond to any
member in an output set. *Sets in Reactome are considered ordered by default.*"_
#link(
    "https://download.reactome.org/documentation/DataModelGlossary_V90.pdf",
)[#underline[DataModelGlossary_V90]]

La riga in grassetto in realtà mi fa pensare che loro memorizzano i set come
"liste", non come veri set. E poi sta all'attributo `isOrdered` dire se il set è
ordinato (effettivamente una lista) o meno (quindi effettivamente un set).

#pagebreak()

*NOTA*: si possono verificare *TRE* situazioni con l'attributo `isOrdered`:
1. l'attributo c'è ed è *true* (il set è ordinato, si verifica in un centinaio
    di casi)
2. l'attributo c'è ed è *false* (il set non è ordinato... si verifica in solo
    due casi)
3. l'attributo NON c'è (io tratto il set come se `isOrdered` fosse *false*)

Il motivo per cui nel punto 3. tratto il set come se `isOrdered` fosse *false* è
perché ci sono reazioni in cui set con `isOrdered = true` e set senza
`isOrdered` hanno un numero diverso di membri (quindi non si potrebbero
accoppiare i membri di un set con i membri dell'altro). Quello che non capita,
infatti, è che due set con `isOrdered = true` nella stessa reazione abbiamo un
numero diverso di membri.

// #pagebreak()

== Algoritmo per generare nuove reazioni a partire da una reazione che coinvolge entityset

In questo esempio c'è un sert ordinato `SET_OUT` che a sua volta ha dentro un
set NON ordinato `SET3`.

#figure(caption: [esempio])[
    #image("./example-1.svg", width: 130%)
] <example-1>

Nella prima iterazione genero nuove reazioni che accoppiando solo i membri al
*primo livello* della gerarchia dei set. Quindi `(E1, E4)`, `(E2, E5)`,
`(E3, SET3)`

#figure[
    #image("./example-1-iteration-1.svg", width: 115%)
]

Nella seconda iterazione, dato che `SET3` non è ordinato, genero una nuova
reazione per ogni membro di `SET3`. Alla fine mi ritrovo con le reazioni in
@result-example-1.

#figure(caption: "risultato")[
    #image("./example-1-iteration-2.svg")
] <result-example-1>


#pagebreak()

#page(height: auto)[
    In realtà, quello che si può verificare, è che allo stesso livello ho sia
    set ordinati, sia set non ordinati, come per `SET_IN`, `SET4` e `SET_OUT` in
    @example-2.

    #figure(caption: "esempio")[
        #image("./example-2.svg", width: 120%)
    ] <example-2>

    Nella prima iterazione faccio questo: genero una nuova reazione per ogni
    coppia che ha lo stesso ordine nei set ordinati, e per ogni membro dei set
    non ordinati.

    #figure[

        #image("./example-2-iteration-1.svg", width: 120%)
    ]
]

A questo punto riapplico l'algoritmo per le reazioni che coinvolgono ancora set,
ottenendo le reazioni in @result-example-2.

#figure(caption: [risultato])[
    #image("./example-2-iteration-2.svg", width: 120%)
]<result-example-2>
