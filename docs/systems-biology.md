# Systems Biology

+ [genYsis](https://www.researchgate.net/figure/Performance-Comparison-between-genYsis-10-and-geneFAtt_fig5_236182496) it computes attractors
+ [Reactome Pathway Databse](https://reactome.org/)
+ [MCMAS](https://sail.doc.ic.ac.uk/software/mcmas/) model checker
+ [CUDD](https://github.com/ivmai/cudd) The CUDD package is a package written in C for the manipulation of decision diagrams.
[Further Material](http:// www.wiley-vch.de/home/systemsbiology)
+ Cell Biology
+ popular biological databases
+ software tools
+ [SBML](https://sbml.org/) exchange format (for computation models in systems biology) (Systems Biology Markup Language)
+ [SBGN](https://sbgn.github.io/) graphical elements
+ [MIRIAM](https://en.wikipedia.org/wiki/Minimum_information_required_in_the_annotation_of_models) Minimum Information Requested in the Annotation of Biochemical Models
+ [MIASE]() helps authors to describe all elements of a computational experiment such that readers can repeat the simulations and create figures as shown in the publication
+ [Gene Ontology](https://geneontology.org/) that provides a controlled vocabulary that can be applied to all organisms, even as the knowledge about genes and proteins continues to accumulate
## Preface

- high throughput experiments
- time series experiments 
- imaging techniques with high resolution

    -> detailed picture of the cellular machinery (how physical strucutres are built, maintained and reproduced)


* mathematical models to capture "global dynamics" between components 
* dynamical systems theory and control theory "applied" to biochemical pathways

(computational models of cells within reach)

It is often difficult to foresee the global behavior of a complex system from knowledge of its parts. Mathematical modeling and computer simulations can help us to understand the internal nature and dynamics of these processes and to arrive at predictions about their future development and the effect of interac­ tions with the environment.

## Computational Models

### Model scope

Systems biology models consist of mathematical elements that describe properties of a biological system, for instance, mathematical variables describing the concentrations of metabolites. It is important to construct models s.t. the disregarded properties do not compromise the basic results of the model.

(by "scope" we mean "model in detail only what we are interestd in, in such a way that the parts which aren't modeled do not interfere with the results)

### Model Statements

Statements and equations describing facts about the model elements (notably, the temporal behavior)
- kinetic model: the dynamics is a set or ordinary differential equations describing the substance balances
- statements might have <= or >= constraints, maximality postulates, stochastic proceses, probabilistic statements etc...

### System State

A system is characterzed by its state (set of variables) it might be 
- a list of susbstance concentrations
- a probability distribution
- the number of molecules of a species

In Boolean model of gene regulations a state is
- a string of 1s and 0s indicating whether a gene is expressed or not

Temporal behavior:
- future states determinated by current state (in dynamic model)
- in stochastic process future states are not predetermined (each history has a certain probability to occur)

### Variables, Parameters and Constants

- constant: fixed value (e.g. Avogadro's number)
- parameters: given value (based on experimental conditions, may change)
- variables: quantities with relations that may change
    - state variables: a subset of variables describes the system behaviour (the other variables depend on them e.g. diameter is state, volume depends on diameter)

### Model Behavior

- influences from environment (input)
- processes within the system

(relations between variables determines how endogenous and exogenous forces are processed)

- system behavior (output)

### Model Classification

Processes are classified based on some criteria:
- A qualitative model (structural model) specifies the interactions among elements
- A quantitative model assigns values to the elements and to their interactions

- A model can be deterministic
- A model can be stochastic (probability successive states)

- Values of time, state or space can be
    - discrete
    - continuous

- A process can be Reversible
- A process can be Irreverisble (only one direction can be followed)

- Periodicity (the system assumes a seres of states in the time interval {t, t + Delta t} and {t + iDelta t, t + (i + 1) Delta t}

### Steady States

Steady
: fixed, constant (as in fixed points)

- steady: the state variables remain constant in time (asymptotically) 
- oscillatory regimes
- chaotic regimes

(basically, if we embed the model in a large stationary environment, it remains steady)

boolean networks are a simplified (gene regulatory networks) model, helps check reliability of basic assumptions and discover nature designs.

### Model Assignment is not Unique

multiple mathematical models can be used for the same problem, a mathematical model can express multiple problems

### Networks

Systems of ordinary differential equations describing metabolite dynamics take metabo­ lites as nodes and enzymatic reactions as edges (Chapter 4), while flux balance analysis restricts itself to steady states and now focusses on the fluxes through the reactions (now as nodes) that are linked by the stationary metabolites as edges.

### Data Integration

Complexity
1. store the data
2. correlate the data

TODO:
- Human Genome Project
- Proteomic technologies have been used to identify the translation status of complete cells (2D gels, mass spectrometry) and to elucidate protein–protein interaction networks involving thousands of components
- Thus, an important part of systems biology is data integration

On the lowest level of complexity, data integration implies common schemes for data storage, data represen­ tation, and data transfer.

- Systems Biology Markup Language (SBML)
- CellML (Cell Markup Language)
- Systems Biology Graphical Notation (SBGN)

Data integration on the next level of complexity consists of data correlation.
The evaluation of disease-relevant data is a multistep procedure involving a complex pipeline of analysis and data handling tools such as data normalization, quality control, multivariate statistics, correlation analysis, visualization techniques, and intelligent database systems

### Model Organisms

Model organisms are species that have developed over the years to be extremely popular for scientific investigations.
Prokaryotes, eukaryotes, unicellular organisms, multicellular organisms, vertebrates, and invertebrates

## Modeling of Biochemical Systems

### Overview of Common Modeling approaches for Biochemical Systems

- network-based approaches
    - describe and analyze properties, states, or dynamics of networks, that is, components and their interactions.
    - frameworks
        - Systems of ordinary diferential equations for biochemical reaction networks
        - Stochastic description of biochemical reaction networks (and birth-death processes or reaction networks with small compound numbers)
        - Boolean models (e.g. gene regulatory networks)
        - Petri net models (metabolic networks or transitions in complex systmes)
    - questions
        - Are compounds densely or loosely connected? 
        - Do we have single important hubs or are all nodes equally well connected? 
        - What is the shortest path to get from one node to another node? 
    - Based on the completed network topology, it is possible to add more detailed information about the nature of the connections or the nodes. This can be kinetic laws for individual reactions or instructions for combining input information arriving at a node from different edges as in Boolean networks.
    - Choice of modelling frameworks
        1. For the variables describing the states of the com­ pounds, we can consider either discrete or continuous values. An example of discrete values is the pair of 0 and 1 used in Boolean networks (Section 7.1) to characterize on/off states of genes due to the presence or absence of transcription factors, respectively. 
        2. Time can be static, dynamic, continuous or discrete time steps (ODE uses continuous time, model approches with deiscrite variables have discrete time) 
        3. The update of states over time can proceed deterministically, or stochastically.

- rule-based models (agent-based models)
    - In rule-based models, every compound of the system can update its state according to a set of rules. 
    - Rule-based modeling lists all potential state changes of the individual compounds, but not all potentially occurring states. That is why it can be computationally less demanding than an ODE system, for example, for signaling systems
    - Cellular automata are regular grids of cells which can assume a finite number of states
        - The agents move freely in the containing space and update their states according to their rules and the environmental conditions.

- statistical models
    - establish relations etween measured data, and provide a guide to extracting underlying structures of the biological systems that gave rise to the data (e.g. linear regression)
    - Support Vector Machines to categorize data (learning algorithms that divide a number of objects into classes)


A biological system has a topology and structure (how design and function relate)

- What question is the model supposed to answer?
- Is it built to explain a surprising observation?
- Is it built to relate separate observations with each other and with previous knowledge?
- Is it built to make predictions, for example, about the effect of specific perturbations?

IMPORTANT: since a considerable amount of data is available in publications, an alternative or addition to new experiments is exhaustive literature research, including text mining as well as systematic screening of databases.

### Defining a Model

1. Define the question that the model shall help to answer.
2. Seekavailable information (Reat the literature, look at the available experimtal data, talt to experts in the field)
3. Formulate a mental model
4. Decide on the modeling concept (network-based, or rule-based, determinstic or stochastic, etc.)
5. Formulate the first (simple) mathematical model
6. Test the model performance in comparison to the available data.
7. Refine the model, estimate parameters.
8. Analyse the system (parametere sensitiviy, static and temporal behaviours, etc.)
9. Make predictions for scenarios not used to construct the model such as gene knowckout or overexpression, application of different stimuli or perturbations
10. Compare predictions and experimental results.

The mother is never "right" but it can be helpful. If the predictions and experiments are different, important aspects of the biological process have not been understood, and one can find missing links or better parameters to explain the observations.

### ODE System for Biochemical Networks

TODO: pag 36, 37 and 38 of the pdf

## Data Formats, Simulation Techniques, and Modeling Tools (pag 81 pdf)

TODO: might prove really useful to understand how to proceed

## Discrete, Stochastic, and Spatial Models (pag 139 pdf, need it for Boolean Networks)

On the one hand, kinetic models may be too complicated: for models of gene expression networks, approximate expression levels may be the only data available. If these data solely allow us to distinguish between active and inactive genes, we should reflect this knowledge by a discrete model: in a Boolean network model, genes can switch between two states (“on” or “off”) and, in doing so, affect the states of other genes.

### Discrete Models

#### Boolean Networks

Boolean models are, perhaps, the simplest representation of dynamic biological networks. However, they have proven to be very helpful to understand complex regulatory networks for which we have not much more information at hand than their nodes (e.g., the genes) and whether they interact. 
By assigning simple rules, we can analyze the potential network behavior in time. Since – at least in the basic version – the numbers of states and state transitions are finite, we can try to investigate the full state space. 
Boolean networks are discrete, both in state and in time.
The most prominent application of Boolean networks has been in the analysis of gene regulatory networks.

Boolean logic has been applied to biological processes such as regulation of gene expression in the framework of Kauffman’s NK Boolean networks [1–4].
Genes are the elements of the network. 
Levels of gene expression are approximated by only two states: each gene is either expressed (is assigned the value "1") or not expressed ("0"). The network has N elements or nodes. Each element has K inputs (regulatory interactions) and one output, that is, its state.

REGULATORY INTERACTIONS OF A GENE
: A gene's regulatory interactions involve a complex network of molecular players that control its expression

An N-dimensional vector of elements can describe the state at time t.

The state changes of an individual element are specified by the Boolean rules that relate the output to the inputs. 
There are 2^(2^k) possible Boolean rules for a node with K inputs. 
The rules can be enumerated according to the respective binary numbers of output or rules can be associated with their meaning in normal life (and, or)

- ATTRACTORS
The sequence of states given by the Boolean transitions represents the trajectory of the system. 
Since the number of states in the state space is finite, the number of possible transitions is also finite. 
Therefore, each trajectory will lead either to a steady state (as in Figure 7.2c) or to a steady cycle (as in Figure 7.2a). 
The cycle length is the number of states on the cycle. 
A steady state is a cycle with length 1. 
These states or state sequences are also called *attractors*.

- TRANSIENT STATES
Transient states are those states that do not belong to an attractor. 

- BASIN OF ATTRACTION
All states that lead to the same attractor constitute its basin of attraction (or confluent)

- PATH LENGTH (or RUN-IN LENGTH)
The path length (or run-in length or transient length) is the number of states between initial states and those entering the attractor.

- AVERAGE PATH LENGTH AND NUMBER OF ATTRACTORS
further important characteristics of a Boolean network are average path length and the number of attractors, which can lie between 1 and N.

- HAMMING DISANCE and NUMBER OF STEPS
There are different ways of measuring the distance between states. 
One way is to enumerate the number of steps on a trajectory to get from one state to the other state. 
Another way is to count the number of different elements in each state vector. 
If N = 5, for example, the difference between the states (1, 0, 1, 0, 1) and (1, 1, 1, 0, 0) would be 2 (for the second and fifth entries). 
This is also called the Hamming distance.

- PERTURBATIONS
Boolean networks can be used to study network perturbations. 
A potential perturbation is the change of a node state (from 0 to 1 or 1 to 0). 
Then one can follow the dynamics of the system, which moves either to the same attractor as before or to another attractor, if this perturbation shifted the system into another basin of attraction.
Further types of perturbations are to change the rules of individual nodes (e.g., from AND to OR) or to modify the network wiring (i.e., to choose different input nodes for a selected node).

#### Advanced Types of Boolean Networks 

- asynchronous Boolean networks
    - In asynchronous Boolean net­ works, a random node is selected at each time point and updated. Repeated simulation of the same network with identical starting conditions can provide an average behavior of the network. The approach of asynchronous updates reflects the experience that in biological networks not all nodes change their states necessarily at the same time.

- random Boolean networks
    - Their major feature is that update rules are chosen randomly during construction. They remain constant over the time course.

- probabilistic Boolena networks 
    - assign with a certain probability update rules to nodes at each time step. Thea have also been used to analyze potential cell fates.

Boolean networks have been used to explore general and global properties of large gene expression networks.
(i.e., each gene has K inputs, and each gene is controlled by a randomly assigned Boolean function)

IMPORTANT Kaufman [3,7]
oth the median number of attractors and the length of attractors are on the order of N^(1/2).

(Figures 7.1, 7.2, 7.3, 7.4)

A 
B

## Dictionary

Omics technologies
: are a suite of advanced techniques used to analyze biological systems on a large scale

Attrattore
: In matematica, un attrattore è un insieme verso il quale evolve un sistema dinamico dopo un tempo sufficientemente lungo. Perché tale insieme possa essere definito attrattore, le traiettorie che arrivano ad essere sufficientemente vicine ad esso devono rimanere vicine anche se leggermente perturbate.

Procarioti vs Eucarioti
: La principale differenza tra i due risiede nella presenza o assenza di un nucleo ben definito

Genomics
: the study of an organism's complete set of DNA, including its genes, and how these genes interact with each other and the environment

Genotype
: genetic code of an individual

Phenotype
: observable charcteristics

Physiology
: how cells interact

Biomarker
: a measurable indicator of a biological state, condition, or disease

Metabolic State
: the metabolic state refers to the body's physiological condition regarding energy production and utilization (ethymology: transformation or change, "meta" after "ballein" to throw)

Biochemical Pathway
: a series of interconnected chemical reactions that occur within a cell, where the product of one reaction serves as the substrate for the next (flow of information)

Proteomics
: the large-scale study of proteomes, which are the complete sets of proteins produced by an organism, cell, or biological system. It involves analyzing protein expression, structure, function, and interactions to understand cellular processes and how they change under different conditions

Systems Biology
: discipline devoted to developing such modesl, uses biochemical networks as main concept

Systems Biology Pt.2
: it studies biological systems by investigating the network components and their interactions with the help of experimental highthroughput techniques and dedicated small-scale investigations and by integrating these data into networks and dynamical simulation models.

Neurodegenerative Disease
: gruppo di patologie che causano un progressivo deterioramento e perdita di cellule nervose nel sistema nervoso centrale o periferico

Statistical Network Analysis
: ??? statistical network analysis, the analysis of the robustness and fragility of dynamical sys­ tems, and the analysis of molecular noise

Statistical Model Checking
: a formal verification technique that combines simulation and statistical methods to analyze stochastic systems.

Stoichiometric Model
: a mathematical representation of a chemical or biological system, describing the relationships between reactants and products in a reaction or process .

Kinetic Model
: a mathematical representation of how biological systems change over time. It describes the rates of chemical reactions and the movement of molecules within a system, often involving differential equations that track changes in concentrations of reactants and products. These models are used to understand, predict, and analyze the behavior of complex biological processes, such as metabolic pathways or cellular signaling, by simulating how these systems respond to different conditions.

Cellular Network
: Cellular network biology is a field that applies network science principles to the study of cells. It examines how different molecules within a cell interact to form complex networks, enabling cellular functions like gene expression, signaling, and metabolism. By analyzing these networks, researchers can gain insights into cellular behavior, identify potential drug targets, and understand disease mechanisms.

Central Dogma of Molecular Biology
: enes code for mRNA, mRNA serves as template for proteins, and proteins perform cellular work 

Evolution Makes Organisms Similar
: Applications include, for example, prediction of protein function from similarity, prediction of network properties from optimality principles, reconstruction of phylogenetic trees, or the identification of regulatory DNA sequences through cross-species comparisons.

Central Dogma of Transcription and Translation 
: ???

Biochemistry of Enzyme-Catalyzed Reactions
: ???

Model
: a model is an abstract representation of objects or processes that explains features of these objects or processes. In experimental biol­
ogy, the term “model” is also used to denote a species that is especially suitable for experiments; for example, a genetically modified mouse may serve as a model for human genetic disorders.

Dots for Metabolites and Arrows for Reactions
: a substance formed in or necessary for metabolism (where metabolism is a transformation)

Cellular Transcription Networks
: complex systems of interacting molecules that regulate gene expression

Converting enzymes
: are a class of enzymes that facilitate chemical reactions by modifying the structure of a molecule

TODO:
e.g., Michaelis–Menten kinetics holds for many enzymes, the promoter–operator concept is appli­ cable to many genes, and gene regulatory motifs are com­ mon

The phrase
“essentially, all models are wrong, but some are useful” coined by the statistician George Box is indeed an appro­ priate guideline for model building.


PAGE 24 pdf, sec. 1.3
