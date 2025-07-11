# Taming Asynchrony for Attractor Detection in Large Boolean Networks

Boolean networks is a well-established formalism for modelling biological systems. A vital challenge for analyzing a Boolean network is to identify all the attractors.
This becomes more challenging for large asynchronous Boolean networks, due to the asynchronous scheme.
Existing methods are prohibited due to the well-known state-space explosion problem in large Boolean networks. 
In this paper, we tackle this challenge by proposing a SCC-based decomposition method. We prove the correctness of our proposed method and demonstrate its efficiency with two real-life biological networks.


- ME VERSION: We want to find the attractors, in large asynchronous networks is hard (State Space explosion, nice), so we decompose the network in SCC (Strongly Connected Components) 

# Introduction

A *GRN* _(Genere Regulatory Network)_ is a collection of molecular regulators that interact with each other and with other substances in the cell to govern the gene expression levels of mRNA and proteins which, in turn, determine the function of the cell.

A *molecular regulator*  is a molecule that controls the activity, expression, or function of other molecules or processes within a cell or organism.

An attractor of a biological system is a set of the system’s states satisfying that any two states in this set can be reached from each other and the system remains in this set until some external stimulus pushes the system out of it.

Attractors are hypothesised to characterise cellular phenotypes or to correspond to functional cellular states such as 
- proliferation (the process of cell growth and division, resulting in an increase in the number of cells)
- apoptosis (the process of programmed cell death, in which a cell initiates self-destructions; necrosis is a 'messy' uncontrolled cell death)
- differentiation (the process where a less specialized cell develops into a more specialized cell type, acquiring distinct characteristics and functions)
- homeostasis (a finely tuned balancing act involving the interplay of various cellular processes such as oxidative phosphorylation, autophagy protein ubiquitination, and sumoylation. These pathways work in harmony to ensure cells function optimally, adapting to changes and stressors)


## Attractor detection

1. Enumeration
    - In the early 2000s, an enumeration and simulation method has been proposed. 
    - The attractors are detected by running simulation from each of the possible states. 
    - This method is largely restricted by the network size since the required computational time grows exponentially with the number of nodes.
2. Irons 
    - 2006 method to handle BNs with maximum 50 nodes
3. BDDs (Binary Decision Diagrams)
    - Basically decision trees
    - It has efficient operations to compute forward and backwrd reachable states
    - To identify attractos it's enough to identify the fix point set in the corrisponding transition system
4. SAT solvers
    - The transition relation of the BN is unfolded for a bounded number of steps, and it's presented as a propositional formula
    - The process is repeated for bigger bounds until no valid path can befound
    - It depdends on the number of nodes in the BN and the number of unfolding steps required
5. BNs decomposition
    - The main idea is to decmpose a large BN into small components based on its structure, detect attractors in the small compoments, and then recover the attractors of the original BN 
6. other methods for large networks (cannot guarantee to find all attractors)
    - approximation methods
    - reduction methods
    - methods designed for specific types of attractors


## Asynchrony

The above mentioned methods are mainly designed for BNs with the synchronous scheme, i.e., BNs where the values of all the nodes are updated simultaneously. In biology, however, the update speed of each node is not necessarily the same. Updating node values asynchronously is considered more realistic.

BSCCs

# Preliminaries

## Boolean Networks

### Boolean network

- predictor function
- parent node
- child node
- state

- synchronous (all values updated at the same time)
- asynchronous (one variable is updated at a time)
    - it's more suitable for gene expression for GRNs as the expression of a gene is usually not an istantaneous process

- transition relation
    - T(x(t), x(t + 1)) = and.big_(j=1, j != i)^n (x_j(t + 1) <-> xj(t)) and (x_i(t + 1) <-> f_i(x_i_1(t), ..., x_i_(k(i))(t)))
    - node v_i is updated according to the transition relation, and the other remain unchanged
    - each node has a change to be updated by its Boolean function (from a state there are n outgoing transitions)

### State transition system (STS)

A STS is a 3-tuple <S, S_0, T> where
- S is a finite set of states
- S_0 subset.eq S is the inital set of states
- T subset.eq S times S is the transition relation

When S = S_0, we write <S, T>

An asynchronous BN can be easily modelled as a state transition system
- S is the state space of the BN (2^n states with n nodes)
- S_0 = S
- T is given by the transition relation above

### Attractor

An attractor of a BN is a set of states satisfying that any state in the set can be reached from any other state in this set and no state in this set can reach any other state that is not in this set.

Attractors are hypothesised to characterise cellular phenotypes.

We refer to an attractor togeher with its state transition relation as an attractor system (like an STS).
- its state are called attractor states
- it is not guaranteed that an asynchronous attractor is a loop
- in asynchronous systems the attractor might inculde serveral loops

Types of attractors:
- singleton attractor (a selfloop)
- simple loop
- complex loop

One can detect self-loops and simple loops by checking the synchronous version of the BN, but the same can't be said for complex loops (special algorithms are required to detect such attractors).

## Encoding BNs in BDDs

A BDD has a root node, intermediate decision nodes and two terminal nodes (it encodes a boolean function)
- they are memory efficient 
- applied to model checking to alleviate the state-space explosion

Encoding
- each variable in V can be represented by a binary BDD variable
- to encode the transition relation a set V' (a copy of V) of BDD variables is introudced

# Method

SCC-based decomposition method.
1. Divide the BN into sub-networks called blocks (efficient, depends on structure)
2. Detect attractors of each block (performed on the costructed STS of each block, exponentially reduced in size)
3. Recover attractors of the original BN by merging the detected attractors of the block

## Decomposition of a BN into Blocks

### Block

a block B(V^B, f^B) is a subset of the network where V^B subset.eq V and f^B is a list of Boolean function for nodes in V^B s.t. for any node v_i in V^B, if B contains all the parent nodes of v_i, its Boolean funtion in B remains the same sa in G, otherwise the Boolean funciton is undetermined, meanding that additional information is requiredto determine the value of v_i in B. 

UNDETERINED NODE
A node with an indetermined Boolean function is called an indetermined node
A Block is an elementary block if it contains NO undetermined nodes

### SCC

Let G be adirected graph, and V itsvertices. A strongly connected compoenent of G is a maxmial set of vertices C subset.eq V such atath for every pair of vertices (u, v) in C, there is a directed path from u to v and vice-versa

We decompose a BN into SCCs
- a CONTROL NODE is a node outside an SCC that is a parent to a node in the SCC

### Parent SCC, Ancestor SCCC

An SCC X is called a parent SCC of another SCC Y if it contains at least one control node of Y. 
Denote P(Y) the set of parent SCCs of Y.
An SCC K is called an ancestor SCC of Y if and only if either K is a parent of Y or K is a parent of Y's ancestor
Omega(Y) to tdenoe the set of ancestor SCC

An SCC together with its control nodes forms a BLOCK
- parent and ancestor naturally extend to BLOCKS (if a control node of a Block B_i is a determined node in a block B_j)
- adding directed edges from all parent block to theri child blocks we form a DAG (as blocks are formed of SCCs, so if it enters into a SCC it cannot come outside, smart)

MERGE
two blocks can be merged to form a larger block 

STATE
A state of a block is a binary vector of length equal to the size of the block, which determines the values of all the nodes in the block


### Projectio map, Compressed state, Mirror states (operations on states)

- the projecto map delta_B : X -> X^B is given by X = (x_1, x_2, ...., x_m, x_(m + 1), ..., x_n) |-> delta_B(x) = (x_1, x_2, ..., x_m)
    - basically take all the parts of a state that matter in that block 
    - it's called a "compressed state of x"
- it can by applied to any set of states (and get sets of projections)
- it can also be applied to blocks

- mirror states is M_G(S^B) = {x | delt_B(x) in S^B }
    - basically all the states of the BN that compressed give S^B

## Detection of Attractors in Blocks

(Kruskal lineare)
- first consider the case of elementary blocks (elementary blocks are BNs)
- attractors in an elementary blocks are attractors in a normal BN

### Preservation of attractors

Given a BN G, and an elementary block B in G, let A = {A_1, ... A_m } the set of attractors of G, and A^B  = {A^B_1, ..., A^B_m} be the set of attractors of B. We sa that B preserves teh attractors of G if for any k in [1, m] there is an attractor A^B_k' in A^B such that delta_B(A_k) subseteq A_^B_k'

*Lemma 1* Given a BN G and an elementary block B in G, let phi be the set of attractor states of G and phi^B be the set of attractors states of B. If B preserves the attractors of G, then phi subset.eq M_G(phi^B)

*Theorem 1* Given a BN G, let B be an elementary block in G. B preserves the attractors of G.

NON ELEMENTARY BLOCKS

- a non elementary block must have some ancestor which is elementary;
- together with all the ancestors they form an elementary block which is also a BN
- use the detected attractors to guide the values of the control nodes of their child blocks
    - the guidance is achieved by considerin realisations of the dynamics of a child block with respect to the attractors of its parent elementary block
    - (in some cases it can be done by assignin new Boolean fhnctions to the control nodes of the block)

### Crossability, Cross operations (merge attractors of two blocks when recovering the attractors of the original BN)

CROSSABILITY
two states x^(B_i) and X^(B_j) are said to be crossable, denoted as X^(B_i) C x^(B_j) if the values of their common nodes are the same, i.e. y^i_k = y^j_k for k in \[1, t\]
- the CROSS operations naturally extends two elementary blocks
- any two sates of any two elementary blocks are always crossable

Two SUBSETS of states of different blocks are crossable if 
- at least one of them is empty
- either one of the following holds
    1. for any state x^BI there always exists a state x^Bj such tath x^Bi and x^Bj are crossable
    2. vice-versa

PI(S^B_i, S^B_J) = { PI(x^B_i, x^B_j) | x^B_i in S^B_i AND x^B_j in S^B_j AND the two are crossable }
If one set is empty, the cross operation returns the other set

- crossability also extends to the power set

### Realisation of a block

Let B_i be a non-elementary block formed by mergin an SCC with its control nodes
Let nodes u_1, ..., u_3 be all the control nodes of B_i which are also contained by its single and elemntary parent block B_j
(we can always merge all B_i's ancestro blocks to form B_j if B_i has more than one parent block or has a non elmeentary- parent block)
Let A_1^B_j, ..., A_t^B_j be the attractor systems of B_j. For any k in \[1, t\], a relaisation of block B_i with respect to A_k^B_j is a state transition system such that

1. a state of the system is a vector of the values of all the nodes in the block
2. the state space of this realisation is crossable with A_k^B_j
3. for any transition x^B_i -> tilde(x)^B_iin this realisation, if this transition is caused by a non-control node, the transition  should be regulated by the Boolean function of this node;  if this transition is caused by the updating of a  control node, one can find two states x^B_j ... such that there ia a transition from .... etc...
4. for any transition ... in A_K^B_j, one can always find a transition in this realisation that crosses

### Atractors of a non-elementary block

An attractor of a relisation of  a non-elmenetary block is a set of states satisfying that any state in this set can be reached from any other state in this set, and no state in this set can reach any other state that is not in this set. 
The attractors of a non-elmentary block is the set of the attractors of all realisations of the block.

Basically, we need only the attractors of the parent which contain the control nodes of the current block, gg (so attractors propagate). 
It doesn't really matter if the parent is elemntary or not.
We need to consider an order such that when computing the attractors of B_i, the attractors of its parent which contain the control nodes are already available.

### Credit

Given a BN G, an elementary block B_i of G has a credit of 0, denoted as P(B_i) = 0. Let B_j be a non-elementary block and B_j1, ..., B_j_p(j) be all its parent blocks. 

The credit of B_j is P(B_j) = max_(k = 1)^(p(j))(P(B_j_k)) + 1
The credit is the max credit of a parent + 1, kinda sounds familiar with teh topological order, order them by credit.

## Recover Attractors of the Original BN

After recovering the attractors of each block the attractors of the original BN need to be recovered. This is achievable by the following Theorem.

*Theorem 2* Given a BN G with B_i and B_j being its two blocks, let A^B_i and A^B_j be the set of attractors of B_i and B_j, resp. 
Let B_(i, j) be the block got by mergint the nodes in B_i and B_j.
If B_i and B_j are both elementary blocks or B_i is an elmeentary and single parent block of B_j, then A^B_i C (cross) A^B_j and PI(A^B_i, A^B_j) is the set the set of attractors of B_(i, j)

*Corollary 1.* Given a BN G with B_i, B_j and B_k being its three blocks, let ... If the three blocks are all elementary blocks or B_i is an elmentary block and it is the only parent block of B_j and B_k, it holds that ....

IDEA:
- divide a BN into blocks according to detected SCCs
- order the blocks in the ascending order based on their credits and detect attractors of the ordered blocks one by one (iteratively)
- the resulting merged block of a block with credits 0 and credits 1 generates a new elementary block (i.e. with credit 0)
- we repeat this step iteratively until there is one elmenetary block (the original BN)

# Implementation

- introduce BDD-based algorithm to detect attractors for small BNs
- describe how SCC-based method can be implemented by using the BDD-based algorithm

### Bottom SCC

A bottom strongly connected component is an SCC Simga such that no state outside Sigma is reachable from Sigma

## BDD-Based Attractor Detection Algorithm

- encode BN with BDDs
- adapt the hybrid Tarjan algorithm to detect BSCCs in the corresponding transition system ofthe BN
- DETECT(T) where T = <S, S_0, T> computes the set of BSCCs in T.
- if T is converted from a BN G, then DETECT(T) computes the attractors of G

*Proposition 1* The first SCC returned by the Tarjan's algorithm is a BSCC
*Proposition 2* A state is not contained by 

procedure DETECT(T)
    A := emptyset
    X := S
    while X != emptyset do
        Randomly pick a state s in X;
        Sigma := HybridTarjan(s, T);
        A := A union Sigma;
        X := X  Predecessors(Sigma, T);
    end while
    return A
end procedure

## SCC-Based Decomposition Algorithm

It's a big ass monster

# Evaluation


