TODO: stiff differential equations
TODO: https://github.com/sys-bio/roadrunner (SBML simulator)
TODO: www.bionumbers.hms.harvard.edu

- Chapter 2 for ODEs
- Chapter 15 for ODEs
- (Partial) PDEs + VCell for Partial
- Chapter 17: other simulation tools (+[13-16])
- MIAME (Minimum Information About a Microarray Experiment)
- MIAPE (Minimum Information About a Proteomics Experiment)
- MIRIAM (Minimum Information Requested in the Annotation of Biochemical Models)


- WTF is a first-order reaction

## ODEs

An early method for the numerical solution of ODEs was derived by Euler in 1768.
fourth-order Runge–Kutta algorithms and implicit methods that can also handle socalled “stiff” differential equations.

A small step size yields a high accuracy, but it also leads to longer computation times.
(adjust step size dinamically to reduce error to epsilon)

Runge–Kutta–Fehlberg method [3], LSODA [4,5], CVODE [6], or LIMEX [7]

ODEs can be used to describe systems in which the components are homogeneously distributed. 
It is, for instance, often assumed that the molecules inside a cell are homogeneously distributed, although this is clearly a simplification. 
In reality, molecules are synthesized or imported at a specific location and are then transported by 
- active (e.g., along microtubules) or 
- passive (diffusion)cytosol mechanisms within the cytosol.

## Stochastic stuff ...

A (k1)-> B + C
C + D (k2)-> E

S=(#A, #B, #C, #D, #E) // state

# Simulation Tools

Modeling systems requirements (generic stuff, not useful):
- well-defined internal sstructure for representation of model components and reactinos
- user-friendly interface
- graphical reaction netwroks
- detailed description of mathematical model
- integrated simulation engines for deterministic and stochastic simulations
- graphical representation of those simulation results
- functionalities for model analysis and model refinement

- [CellDesigner](https://www.celldesigner.org/) [16,17]
    - graphical model development (not my case!)
    - user-friendy process diagram editor
    - uses SBML (for model representation and exchange)

- [COPASI](https://copasi.org/)
    - similar to CellDesigner
    - provides a multitude of methods for simulation, model analysis, and refinement such as parameter scan­ ning, metabolic control analysis, optimization, or parame­ ter estimation.
    - works with stochastic simulation algorithms too

- [VCell](https://vcell.org/)
    - PDEs

## In depth (later...)

# Data formats

## SBML

- XML based
- [SBML](https://sbml.org/)
- [GitHub](https://github.com/sbmlteam)
- used for cell signaling pathways, metabolic pathways, gene regulation, and others
- In July 2015, the [SBML Software Matrix](https://github.com/sbmlteam) listed 281 software systems sup­ porting SBML
- there are three SBML specifications denoted Level 1, Level 2, and Level 3

- FORMAT (the most important lists that are frequently used are 
    - the definition of units, 
    - of compartments 
    - of species
    - the reactions themselves

- MathML (XML-based markup language especially created for the representation of complicated mathematical expressions)

Rate laws in SBML are expressed in terms of amount of substance abundance per time instead of the traditional expression in terms of amount of substance concentration per time.

This is done because attempting to describe reactions between species located in different compartments that differ in volume by the expression in terms of concentration per time quickly leads to difficulties.

## BioPAX

- more  generic tha SBML

## SBGN

- graphical notatiom, might be useful for debugging later

# General Databases

## PathGuide

Pathway-related data and information are of major importance for systems biology.
PathGuide is a pathway resource list giving an overview of web-accessible biological pathway and network databases.
- 547 resources providing information about biological pathways and molecular interactions

## BioNumbers

For biological properties, numerical values are some­
times difficult to find in the literature. Most quantita­
tive properties in biology depend on the context or
the method of measurement, the organism, or the cell
type. Often, however, the order of magnitude is
already a very useful information for modeling. BioN­
umbers (www.bionumbers.hms.harvard.edu) is a data­
base of useful biological numbers [36]. It allows you to
easily browse or search for many common biological num­
bers that might be difficult to find but can be very impor­
tant for modeling, such as the rate of translation of the
ribosome or the number of bacteria in the gut. BioNum­
bers is a community effort to make quantitative properties
of biological systems easily available together with full
references

# Pathway Databases

- The development of models of biochemical reaction networks requires information about the *stoichiometry* and *topology* of the reaction network

## KEGG

- http://www.genome.ad.jp/kegg/
- reference knowledge base offering information about genes and proteins, biochemical compounds and reactions, as well as pathways

- THREE parts:
    - gene universe (GENES, SSDB and KO databases)
    - chemical univers (with the COMPOUND, GLICAN, REACTION and ENZYME databases) (merged as LIGAND)
    - protein network (PATHWAY database)

## Reactome

# DEFINITIONS

- cytosol: liquid component of a cell in which granuels float
