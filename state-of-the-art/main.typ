= State of the art report

#let IMPORTANT = text(red.darken(25%))[IMPORTANT!]


- #IMPORTANT https://zenodo.org/records/17885158 (REACTOME< but cool downloads)
- #IMPORTANT https://reactome.org/download-data

- https://link.springer.com/article/10.1186/gb-2010-11-5-r53 ok WHAT??

- https://www.liebertpub.com/doi/abs/10.1089/cmb.2023.0242
    - https://github.com/gkrieg/mmunin
    - https://github.com/annaritz/pathway-connectivity
    - properly modeling the reaction networks that represent such pathways
        requires *directed hypergraphs* where each molecule or compound maps to
        a *vertex*, and each reaction maps to a *hyperedge* directed from its
        set of input reactants to its set of output products. Inferring the most
        likely series of reactions that produces a given set of targets from a
        given set of sources, where for each reaction its reactants are produced
        by prior reactions in the series, corresponds to finding a shortest
        hyperpath in a directed hypergraph, which is NP-complete.
    - We give the first exact algorithm for general shortest hyperpaths that can
        find provably optimal solutions for large, real-world, reaction
        networks. In particular, we derive a novel graph-theoretic
        characterization of hyperpaths, which we leverage in a new integer
        linear programming formulation of shortest hyperpaths that for the first
        time handles cycles, and develop a cutting-plane algorithm that can
        solve this integer linear program to optimality in practice.
    - We demonstrate that our cutting-plane algorithm quickly finds an optimal
        hyperpath—inferring the most likely pathway—with a median running time
        of under 10 seconds, and a maximum time of less than 30 minutes, even on
        instances with thousands of reactions. We also explore for the first
        time how well hyperpaths infer true pathways, and show that shortest
        hyperpaths accurately recover known pathways, typically with very high
        precision and recall.

- https://ieeexplore.ieee.org/abstract/document/4605956 (2008)
    - Modeling systems biology from the point of view of discrete and hybrid
        systems

- #IMPORTANT
    https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1007384
    (2019)
    - We examined the connectivity of Reactome signaling pathways using four
        different pathway representations. We find that Reactome is:
        - very *well* connected as a *graph*
        - *moderately well* connected as a *compound graph* or *bipartite graph*
        - *poorly* connected as a *hypergraph* (which captures many-to-many
            relationships in reaction networks)
    - We present a novel relaxation of hypergraph connectivity that iteratively
        increases connectivity from a node while preserving the hypergraph
        topology

- #IMPORTANT https://academic.oup.com/nar/article/54/D1/D673/8326464 (Reactome
    2026, published 2025... ok, figata)
    - https://watermark02.silverchair.com/gkaf1223.pdf?token=AQECAHi208BE49Ooan9kkhW_Ercy7Dm3ZL_9Cf3qfKAc485ysgAAA1IwggNOBgkqhkiG9w0BBwagggM_MIIDOwIBADCCAzQGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMPGluV_x8K4Vn0hzLAgEQgIIDBVv4BdY3wEpXPbU0eReguItn9XtbTZQt2xynKa-X-zafVmaSqyjlKo4hhu73lUI__rwoDdpQvLGDyxGZ3TKnFkqBJnJPJHEvvXLm3cW-NIpYabISXMgSbnYEf6wpPCkUW8pZ5EX6FZoZ301Maq6FCrAL0_P53mzbrkzg9mku78CqkOiIWyB48FkWhLZA-saNXqpvZGmskzd2SspXlpgRnlbl_9iOyv6Fhtc6ipFtvtCrzLEYiaMJjQGSHFZj7KBLfSJfDf1acsIgZ91Q70PaxC2-3ILWM1joB4c-VswgOkeT1QLklQsIhsi92Zl-E1P0MppGGAfoMrGcF1quKbZabAoci5K-owK_lNdCjJd37_nVWbCKgWsTreZxYvc7vFKcr9VzlAgY1mJ5IDhYLXoezDnISt7UDeRRjCAGArPA_j3J5XpBSj_Fgmbm29vAJv4OBStT0AkoPvlKpqdZ0sDE-JEE5VVzVHOVAbhWG5fCrt9clw-0Tcf02RrAB-I7FU2PsSYxidFMvSqYdGUmqA9W2wlLJHPwqgPGflX3qE4GQZcrgc8NtmxZEYlovGIL4bHTs40wY6iIuUOAQySwc8LtflaSq0Va1lJs7jVkZ7rev0dpO7uPoPG8RusrLumqpa7B5DP4gKeB7bSdE9ZDmy_vb63wFUONhWzWfjaiCO7uX_TFf93gBjJcv8eFEDc3IX2NhQIf6sHVwed9-kwnnwfPw2XYjOFAs-A38_H0Sx_ZkbwM3aySuQI1tEKkqZ5Xzjytkz0Qb5dKhx9_i28U9t_fd0chxnAm7Rz6DD_m6vDsJZtO-R0qwx2_Pn3GiUyP_jYrfpX5WNId_ejobvSltmUj0BAjJjOQRA32x_rhTIwKmVuuxVIS2pGCsGiIJ3Y5o8hUANSnfvJw7LxQqLI_WRuxqKUD8JkAXU7qfLxLj9-DVUUmI5HT892HRAotEn_OOBaTAtn8b_CwJ0zHaUk45x6SFiRiE3dLC3ccOVkjAqeAXOsb6SbmDG0-o1AoMzf7Ogma5EhkcNdS
    - SEE ALSO: https://academic.oup.com/nar/article/52/D1/D672/7369850 (2024)
    - SEE ALSO: https://academic.oup.com/nar/article/50/D1/D687/6426058 (2022)

- https://link.springer.com/article/10.1186/s13015-022-00217-9 (2022)
    - mi pare di averlo già visto?? Non è roba del problema di Linear
        Programming?

- https://link.springer.com/chapter/10.1007/978-3-642-20149-3_32 (2014)
    - reachability in a graph where edges have a certain "probability" to appear

- https://www.biorxiv.org/content/10.1101/593913v2.abstract (2019)
    - già visto ma su un altro sito (devo solo metterlo insieme)

- https://link.springer.com/article/10.1186/1752-0509-8-30 (2014)
    - nah, non mi convince very much, potrebbe comunque essere utile

- https://link.springer.com/chapter/10.1007/978-3-031-65887-7_1 (2024)
    - cita i boolean network, con "dozzine" di cose... boh

- https://ieeexplore.ieee.org/abstract/document/4402003 (2007)
    - SAME AS https://scholarsarchive.byu.edu/facpub/225/
    - (useless for me, at least from the abstract)

== Making efficient queries

- https://dl.acm.org/doi/abs/10.1145/1376616.1376677 (2008)
    - make efficient reachability queries (not for me)

- https://dl.acm.org/doi/abs/10.1145/1871437.1871625 (2010)

- https://dl.acm.org/doi/abs/10.1145/1989323.1989419 (2011)


=== GIPPITTY

Skip to content
You said:
Is there a paper where someone takes the reactome pathway database and generates a biological network from it?
ChatGPT said:

Yes — there are published works where researchers have taken the Reactome pathway database and generated biological networks (graphs) from it for analysis, rather than just using it as a static collection of pathways. Here are several useful references and examples:
📌 1. Reactome Functional Interaction (FI) Network & ReactomeFIViz

One of the most widely cited approaches builds a network of functional interactions from Reactome pathways:

    ReactomeFIViz (Reactome FI Cytoscape app):
    This tool constructs a large-scale protein functional interaction network by extracting interactions from Reactome pathways and integrating them with other evidence sources. It allows conversion of pathway information into network form for visualization and analysis in Cytoscape.

    The associated work “A human functional protein interaction network and its application to cancer data analysis” (often referenced in the ReactomeFIViz context) discusses how reactions in Reactome are converted to pair-wise functional interactions and assembled into a broad biological network.

Why this is relevant:
This is a classic example of programmatically deriving a biological network from Reactome’s pathway definitions (reactions, catalysts, activators/inhibitors) and using that network to do systems analysis (e.g., module detection, enrichment, disease associations).
📌 2. Reactome Pathway “Logical Networks”

There are studies that convert Reactome pathways into graph or logical network formats for computational analysis — e.g., representing the directed relationships (inputs/outputs, influences) between molecular entities:

    “Converting Reactome pathways to logical networks”:
    A research article describes a method to take 10 selected Reactome pathways and convert them into “Logical Networks” with nodes and directed edges suitable for graph-based analysis and visualization.

Why this matters:
This isn’t just visualization — it’s explicitly transforming Reactome’s structured reactions into a network/graph model that can be manipulated as a biological network (e.g., for perturbation analysis or systems modeling).
📌 3. Ontology-based Network Representations

There are also works where Reactome’s pathway content is repurposed into ontologies or knowledge graphs:

    HINO (Human Interaction Network Ontology):
    This project converts Reactome BioPAX-encoded interactions into an ontology where pathways, interactions, and components become classes and relations in a formal knowledge graph.

Why this is relevant:
Although not a traditional network like a protein–protein interaction graph, it bridges pathway data and graph/semantic network representations, which are increasingly used in computational biology.
🧠 Summary — Key Papers / Tools
Paper / Tool	What it does
ReactomeFIViz (Cytoscape App)	Builds a large functional interaction network from Reactome pathways and other data for network-based analyses.
A human functional protein interaction network and its application…	Method for extracting pairwise functional interactions from Reactome reactions to form a biological network.
Converting Reactome pathways to logical networks	Paper converting Reactome pathways into graph structures (nodes/edges) for analysis.
HINO ontology from Reactome	Converts Reactome interaction/pathway data into an ontology graph representation.

If you want something that specifically generates a network dataset (e.g., edge list or graph model) you can use directly in Python/R (NetworkX/igraph, etc.) or Cytoscape, the ReactomeFIViz FI network or the logical network conversion approach are the most relevant starting points.

Would you like links to the data formats and downloads (e.g., BioPAX/Neo4j/PSI-MITAB) from Reactome that you can programmatically turn into network graphs?
You said:
Are there any papers in which they generate the network by using "reachability" of some nodes?
ChatGPT said:

Yes — there are research papers where investigators create biological networks from Reactome by using forms of reachability/connectivity analysis of nodes (i.e., determining what nodes can “reach” other nodes in the network and thus defining paths or influence within the system). A key example is:
📌 Hypergraph-based Connectivity / Reachability in Reactome

    “Hypergraph-based connectivity measures for signaling pathway topologies” (Franzese et al., 2019) is a peer-reviewed analysis that explicitly looks at reachability and connectivity of nodes in Reactome pathway networks.

        The authors model Reactome pathways not just as ordinary graphs but as directed hypergraphs that better capture the many-to-many relationships in biochemical reactions.

        They define a B-relaxation distance — essentially a graded notion of reachability from one node to another in the hypergraph — which captures how a molecule (node) can influence downstream molecules within the network topology.

        Using this reachability measure, they quantify the influence of one pathway on another and compare several representations (simple graph, bipartite graph, hypergraph) to see how connectivity patterns change.

This work is particularly relevant if your interest is in generating networks where edges/pathways are defined based on whether one molecule can “reach” another through a sequence of reactions, rather than simply listing direct interactions.
🔍 What this achieves

    Graph construction based on reachability: Nodes are connected if there is a feasible causal path between them under the modeling assumptions (e.g., hyperedges can be traversed once all reactants are reachable).

    Connectivity metrics: The work provides formal definitions of connectivity/reachability (B-connectivity) that generalize beyond simple graph reachability.

    Use in pathway influence analysis: By quantifying reachability, one can see not just direct interactions, but network influence of a source node or pathway on targets, which is a richer biological question than pairwise interactions.

🧠 Why this matters

    Typical Reactome network analyses often treat pathways as static sets of interactions; this paper explicitly treats the database as a computational network and analyzes reachability — which is exactly the kind of biologically meaningful network you seem to be interested in.

    The concept of B-relaxation distance is specifically a parameterized reachability metric in a hypergraph setting: it interpolates between strict hypergraph connectivity and ordinary graph connectivity, giving a tunable notion of reachable nodes from a given source.

If this is the kind of reachability-based network generation you meant, I can provide a PDF/DOI link, code resources, or explain how to implement such reachability analyses in Python/R your self — just let me know what direction you want to explore next!
You said:
Are there any papers in which they use BBO (blackbox optimization) to find kinetic constants of networks generated through reachability in Reactome?
ChatGPT said:

Short answer: *there are no well-known papers specifically combining all three elements — (1) generating a biological network from Reactome reachability, (2) formulating a kinetic model from that network, and (3) using black-box optimization (BBO) to find kinetic constants for such a model — as a single published study. However, there are research areas and several relevant works that each cover parts of this pipeline, and in combination they illustrate how it could be done.

Here’s a breakdown of what exists in the literature and where the gaps are:
🔹 1) Black-box / Global Optimization for Kinetic Parameter Estimation

While not tied to Reactome or reachability networks per se, a number of parameter estimation studies in systems biology explicitly use global or black-box optimization methods to fit kinetic constants in biochemical network models:

    Meta-heuristic and evolutionary algorithms (e.g., differential evolution, particle swarm optimization) have been used for kinetic parameter estimation in dynamic biological ODE models, illustrating how black-box optimization can be effective for high-dimensional, nonlinear systems.

    Several global and Bayesian optimization frameworks have been developed specifically for estimating kinetic parameters in complex models, often outperforming traditional least-squares fitting.

    Specific recent work employs Bayesian optimization combined with model hyperparameter tuning in mechanistic models, which is effectively a black-box search over parameter space to match observed dynamics.

    Tools like pyPESTO provide general black-box parameter estimation infrastructure for dynamic models, capable of optimization and uncertainty quantification.

👉 None of these papers specifically derive the kinetic model from Reactome reachability networks, but they do show that BBO is used for parameter fitting in kinetic biological network models.
🔹 2) Kinetic Modeling of Biological Networks

There is extensive literature on transforming network/pathway representations (often from curated resources such as BioModels or pathway databases) into kinetic ODE models. However:

    These studies generally focus on parameter estimation using data or mathematical frameworks rather than reachability-based network generation from Reactome.

    Reviews on systems biology parameter estimation outline how global optimization and meta-heuristics are applied to biochemical model calibration — effectively solving a black-box problem where the simulation outputs are compared against experimental data.

🔹 3) Reachability Networks and Reactome

There are studies that do use Reactome to derive networks and analyze reachability/connectivity:

    Research has used hypergraph representations of Reactome pathways to define notions of connectivity and reachability between biochemical species (e.g., work on hypergraph connectivity and B-relaxation distance). (Referenced in our earlier conversation)

    These reachability-focused analyses are topological rather than kinetic: they identify paths or influence patterns but do not typically produce kinetic ODE models.

🚧 Key Gap in the Literature

To date, academic literature does not appear to contain a published paper that explicitly combines:

    Reactome reachability-based network extraction — i.e., deriving a graph/hypergraph from Reactome pathways using reachability analysis,

    Automatic construction of kinetic ODE models from that network (assigning kinetic laws to interactions), and

    Black-box optimization (BBO) techniques to estimate kinetic constants for that model based solely on data or desired system behaviors.

This combined workflow — Reactome reachability → kinetic model → BBO for parameter estimation — is conceptually feasible but hasn’t been demonstrated as a single formal study in the literature.
🧠 Use Cases Where Pieces Exist

Here are relevant categories of work you can build on:
✅ Black-box / Meta-heuristic Parameter Estimation

    Meta-heuristic optimization applied to dynamic kinetic models of signaling or metabolic networks.

    Bayesian optimization for kinetic parameter estimation in complex mechanistic models.

✅ Kinetic Model Construction from Pathway Databases

    Strategies exist to generate kinetic models from genome-scale metabolic networks or curated pathway repositories, though often with manually assigned kinetic laws and not exclusively via reachability.

✅ Network Morphology from Reactome Reachability

    Work using hypergraphs and reachability metrics explicitly analyzes Reactome networks in a graph context (nodes reachable through reactions), although not directly used for kinetic model creation.

📌 Summary
Aspect	Found in Literature?
Reactome → network via reachability	✔️ (in topological analyses)
Kinetic ODE models of biological networks	✔️ (general systems biology work)
BBO for parameter estimation in kinetic models	✔️ (many studies, meta-heuristic/Bayesian)
Reactome reachability → kinetic model → BBO parameter fitting	❌ (no single published study found)

If you’d like, I can point you to specific parameter estimation tools and example workflows that are commonly used to perform black-box kinetic fitting on SBML/ODE models derived from pathway data — which you could adapt to a Reactome-derived network.


ChatGPT can make mistakes. Check important info. See Cookie Preferences.

- https://github.com/gkrieg/mmunin
- https://github.com/annaritz/pathway-connectivity
- https://pubmed.ncbi.nlm.nih.gov/24324546/
- https://www.researchgate.net/publication/220547753_Parameter_Estimation_Using_Meta-Heuristics_in_Systems_Biology_A_Comprehensive_Review
- https://pmc.ncbi.nlm.nih.gov/articles/PMC4184317/?utm_source=chatgpt.com
- https://reactome.org/docs/training/ReactomeFIVizapp.pdf?utm_source=chatgpt.com
- https://academic.oup.com/database/article/doi/10.1093/database/baac009/6555052?utm_source=chatgpt.com&login=false
- https://arxiv.org/abs/1311.3355?utm_source=chatgpt.com
- https://journals.plos.org/ploscompbiol/article?id=10.1371%2Fjournal.pcbi.1007384&utm_source=chatgpt.com
