#set text(font: "New Computer Modern", lang: "en", weight: "light", size: 11pt)
#set page(margin: 1.75in)
#set par(leading: 0.55em, spacing: 0.85em, justify: true)
#set heading(numbering: "1.1")
#set underline(offset: 2pt, stroke: .25pt)
#set math.equation(numbering: "(1)")

#show raw: set text(font: "LMMonoLt10", size: 11pt)
#show sym.emptyset: sym.diameter
#show sym.space.nobreak: $quad$

#show figure: it => {
    show sym.space.nobreak: sym.space
    it
}

#show ref: it => {
    show sym.space.nobreak: sym.space
    it
}

#show "OpenBox": `OpenBox`

#show heading.where(level: 2): it => {
    show raw: it => {
        set text(size: 1.35em)
        it
    }
    it
}

#let TODO(body) = text(luma(125), font: "LMMonoLt10", size: 11pt, [(TODO -
    #body)])

#let definition(name, body) = context {
    [
        #heading(outlined: false, numbering: none, level: 4, {
            [Definition]
            counter("definition").step()
            math.space
            context counter("definition").display()
            [ (]
            text(style: "italic", name)
            [)]
        }) #label(name.replace(" ", "-"))
    ]

    box(inset: (left: .5em), body)
}

#let algorithm(name, body) = context {
    box(width: 100%, inset: (y: .5em), stroke: (y: .25pt), {
        counter("algorithm").step()
        strong({
            [Algorithm ]
            context counter("algorithm").display()
            [: ]
        })
        name
    })
    box(
        width: 100%,
        inset: (left: measure($quad$).width, bottom: .75em),
        stroke: (bottom: .25pt),
        body,
    )
}

#let grid = 5pt

#let resize(blocks, extra) = (blocks * 4 + extra) * grid

l'intenzione originale non era di scrivere tutte queste pagine, però è finita
così

#align(center + horizon, heading(numbering: none, outlined: false)[
    Scalability analysis of state-dependent asynchronous computations])

#outline()

#pagebreak()


= Introduction

When analyzing the scalability of a parallel algorithm on a HPC cluster, an
interesting problem is the one of trying to predict how would the algorithm
scale on a cluster with a higher degree of parallelism compared to the one
available for experiments.

This document presents one possible way to make this kind of analysis when the
computation is *asynchronous* and the sequence of values in the computation
depends on the state of an *orchestrator*.
//and what hypotheses are needed in order to maintain correctness without requiring the computation to be synchronous.

OpenBox, a system design for generalized black-box optimization @open-box, will
be the main case study for this type of systems.

== Optimization architecture with OpenBox

OpenBox is an efficient open-source system designed for solving generalized
black-box optimization (BBO) problems. It can be used either as a Standalone
python package or Online BBO service @open-box.

OpenBox has a great support for bayesian optimization, so that will be the main
subject of the analysis @open-box-automatic-algorithm-selection.

Given a function $f: X -> Y$, which is expensive to compute, and an optimization
problem of the type $"argmin"_(x in X) space f(x)$, the OpenBox service acts as
an advisor which, when prompted, *suggests* the next point $x$ on which to
compute the value $f(x)$. When a `worker` computes $f(x)$ it sends OpenBox an
*observation*; each observation changes the state of OpenBox. When using the
OpenBox as Service, the _worker needs to actively ask for the points_.

#figure(
    image("./open-box-worker.svg", width: resize(9, 3)),
    caption: [OpenBox simple workflow],
) <open-box-worker>

To generalize the workflow to multiple workers the orchestrator-workers
architecture is used in this report, allowing more flexible algorithms.

#figure(
    image("./open-box-cluster.svg", width: resize(18, 1)),
    caption: [OpenBox workflow with multiple workers],
) <open-box-cluster>

OpenBox has a parameter called `random_state`, which is the _seed_ used by the
pseudo-random function, so, given an initial `random_state`, the *history* of
OpenBox is *deterministic*, an essential feature for reproducibility in
scalability analysis. The order in which the observations are sent to OpenBox
influences its state.

== The problem of scalability analysis

#definition("parallelism degree")[
    Given a HPC cluster $H$, the parallelism degree of $H$ is the number of
    cores available on the cluster.
]

#definition("computation")[
    Given a cluster with parallelism degree $k$, a distributed computation $C$
    is a tuple $(S, t, delta)$ s.t.
    - $S = { s_1^1, ..., s_n^k }$ is a set of simulations where $s_i^c$ is the
        $i$-th simulation computed on core $c$ of the cluster
    - $t : S -> RR^+$ is the initial time of each computation
    - $delta: S -> RR^+$ is the duration of each computation
    - $forall s_i^c, s_j^c quad i < j ==> t(s_i^c) + delta(s_i^c) <= t(s_j^c)$,
        i.e. computations on a single core are sequential
]

A computation on the architecture in @open-box-cluster can be executed either
synchronously or asynchronously.

#definition("synchronous computation")[
    A computation $C = (S, t, delta)$ is a synchronous computation if

    $
        & forall s_i^c, s_j^d quad c != d ==> not space (t(s_i^c) <= t(s_j^d) <= t(s_i^c) + delta(s_i^c))
    $ <synchronous-property>
]

#figure(
    image("./example-sync-computation.svg", width: resize(12, 1)),
    caption: [synchronous computation],
) <example-sync-computation>

#v(10pt)

In the synchronous computation all the workers receive their points at the same
time, and the observations are sent to OpenBox only when all the workers
complete their computation. This type of parallelization is less efficient,
because a lot of time is lost in waiting for the more expensive points to be
computed (@example-sync-computation).

Despite being less efficient, it's easier to predict how a computation would
scale on a bigger cluster (to emulate a cluster with degree of parallelism $n$
it's enough to ask for a batch of $n$ points, simulate all of them and only then
send the observations to OpenBox).

#definition("asynchronous computation")[
    All computations which do not have the property in @synchronous-property are
    asynchronous.
]

#v(10pt)

#figure(
    image("./example-async-computation.svg", width: resize(12, 1)),
    caption: [asynchronous computation],
) <example-async-computation>

#v(10pt)

#image("./example-legend.svg", width: resize(11, 1))

The obvious advantage of the asynchronous computation is that it can generally
simulate more points in the same amount of time.

The problem with the asynchronous computation when analyzing its scalability is
that the state of OpenBox changes more frequently, and some states reachable in
a cluster with higher degree of parallelism are *impossible to reach* in a
smaller cluster depending on the algorithm chosen for the emulation #TODO[...].

= Equivalence of computations

In order to determine wether an algorithm correctly emulates an asynchronous
computation on a smaller cluster, some kind of formalism is needed to tell if
the two computations are equivalent .

One such formalism is the activity diagram, as it describes tasks (simulations,
with an associated duration) and their dependencies.

#definition("activity diagram")[
    An activity diagram is a *DAG* (direct acyclic graph) $G = (V, E)$ s.t.
    - $V$ is the set of tasks
    - $E subset V times V$ is the set of dependencies on the tasks
    #TODO[not very sure about this formalization for the activity diagram]
]

== Activity diagram derivation

Let's consider the computation described in @example-async-computation-2, where
each *observation* is sent *immediately* after its computation ends. Since the
state of OpenBox changes after each observation, the points suggested for tasks
`1`, `2` and `3` don't depend on any other previous task. On the other hand:
- the point suggested for task `4` depends on the completion of tasks `1` and
    `2` before task `4` starts
- the point suggested for task `8` depends on the completion of tasks `1`, `5`
    and `7` before task `8` starts

In the case of task `8`, it indirectly depends on tasks `2` and `3` too, but
it's enough to look at the most recent task completed on each core, as it's
enough to build the transitive closure of dependencies.

#figure(
    image("./pert-async-computation.svg", width: 260pt),
    caption: [async computation on a cluster with parallelism degree 3],
) <example-async-computation-2>

This type of reasoning can be repeated for each task, and this is in fact the
rule used to derive an activity diagram from the computation.

#definition("activity diagram derivation rule")[
    #TODO[give a separate definition for "computation" (like: "tasks on the same
        core do not intersect") and "asynchronous computation", "simulation",
        "cluster & degree of parallelism" etc...]

    Given an asynchronous computation $C = (S, t, delta)$ s.t.
    - $S = {s^1_1, ..., s^k_n}$ is a set of $n$ simulations on $k$ cores
    - $t : S -> RR^+$ is the initial time of each simulation
    - $delta :S -> RR^+$ is the duration of each simulation

    Let $G = (V, E)$ be the derived activity diagram from $C$ s.t.
    - $V = S$
    $
        & forall s_i, s_j \
        & (s^k_i, s^l_j) in E <==> s^k_i = limits("argmax")_(s^k in S space and space t(s^k) + delta(s^k) <= t(s^l_j)) t(s^k) + delta(s^k)
    $
]

This produces the following activity diagram for @example-async-computation-2.

#figure(
    image("./pert-diagram.svg", width: 260pt),
    caption: [activity diagram],
) <example-2-activity-diagram>

#pagebreak()

== Emulation algorithms

In this section the focus is on possible algorithms for emulation, show the
intuition behind which the trivial algorithm doesn't work, give the definition
of *safety threshold* and an algorithm that uses the safety threshold for the
emulation. Finally, show how the basic safety threshold algorithm is not
efficient, and extend it to make it faster.

=== Trivial emulation

The idea is simple: given a cluster with parallelism degree $m$ just send some
points to the workers, and, as soon as one of them completes a simulation, send
the observation to OpenBox and ask for another suggestion.

#algorithm[Trivial emulation][
    *input*: $m$, degree of parallelism of _physical_ cluster \

    $W <- {w_1, ..., w_m}$, physical workers \
    $W_R <- W$, ready physical workers \

    *while* computation is not interrupted *do*\
    ~ $(w, o, delta) <- "wait_for_result"()$ \
    ~ $W_R <- W_R union { w }$ \

    ~ *while* $W_R != emptyset$ *do* \
    ~ ~ OpenBox$."observe"(o)$

    ~ ~ $w <- W_R."extract"()$ \
    ~ ~ $p <- #[OpenBox]."suggest"()$ \

    ~ ~ $"simulate"(w, p)$
]

*Claim:* given two clusters with parallelism degrees $n$ and $m$ respectively,
s.t. $n > m$ the trivial algorithm run on each of them produces a different
result. #TODO[I don't do the proof, time is tight, but I show an intuition]

*Intuition:* let's consider the activity diagram in @example-2-activity-diagram,
the reason this computation is not synchronous is because there subsets of tasks
like {`1`, `4`, `5`, `7`}, where both tasks `7` and `4` depend on `1`, but `7`
depends on `5` and `4` doesn't. In a synchronous computation this situation
doesn't happen, because, given two tasks either:
- the two tasks are in the same batch, so the two tasks have the same set of
    dependencies
- the two tasks are in different batches, so all their dependencies are
    different

It's easy to see that, if we wanted to run the same computation on a cluster
with 1 core instead of 3, there is no possible permutation of tasks `1`, `4`,
`5`, `7` for which the activity diagram is the same as in
@example-2-activity-diagram.

#TODO[to do this proof, the bigger asynchronous computation doesn't have to be
    trivial ($n - 1$ single big simulations occupy $n-1$ cores since the start,
    and only 1 core is doing different points
]

=== Safety threshold

The idea behind the *safety threshold* is that *observations* are not sent to
OpenBox immediately, they are *delayed until it's safe to send* them and ask for
another point.

The algorithm works by
- creating a "representation" of the bigger cluster (virtual cluster) we want to
    do the scalability analysis on
- running simulations on the available cluster (physical cluster)
- updating the state of the virtual cluster, and using that state to choose when
    to send observations and ask for suggestions to OpenBox

#TODO[see simulation_2.py]

#TODO[see the next page for an example of computation]

#let description = (
    [At the beginning, the safety threshold is at time $0$, so it's safe to
        start all 3 workers],
    [The first event that happens is that tasks `1` and `2` are completed
        (dashed black line), \ but the safety threshold cannot be moved yet,
        since the start time of task `3` is not know \
        it could happen that ideally task `3` is shorter than `1` and `2`],
    [This means we have to wait for task `3` to complete in order to move the
        safety threshold, \
        and start tasks `4` and `5`],
    [#pagebreak() The same reasoning happens when task `5` ends: the safety
        threshold cannot be moved until task `4` completes],
    [],
    [],
    [],
    [],
    [],
)

#page(width: auto, margin: 1in)[
    Legend #image("./safety-threshold.svg", width: 350pt) \

    The safety threshold represent a point in time (a timestamp if you want). On
    the right side of the page, \ the ideal computation on the virtual cluster,
    on the left side the computation on the physical cluster

    #for index in range(1, 9) {
        description.at(index - 1)
        image("./safety-threshold-" + str(index) + ".svg", width: 540pt)
    }

    The biggest problem with this computation is that it doesn't use the
    available physical parallelism, \ as it sequentializes the executions to the
    tasks
]


=== Safety threshold emulation

#algorithm[
    Safety threshold emulation
][
    *input*: $n$, degree of parallelism of _virtual_ cluster \
    *input*: $m$, degree of parallelism of _physical_ cluster \

    $V <- {v_1, ..., v_n}$, virtual workers \
    $W <- {w_1, ..., w_m}$, physical workers \
    $V_R <- V$, ready virtual workers \ // min heap, or something
    $W_R <- W$, ready physical workers \

    *while* computation is not interrupted *do*\
    ~ $(v, w, o, delta) <- "wait_for_result"()$ \
    ~ $v."set_pending_observation"(o)$ \
    ~ $v."time" <- v."time" + delta$ \
    ~ $V_R <- V_R union { v }$ \
    ~ $W_R <- W_R union { w }$ \

    ~ *if* $min_(v in V) v."time" < min_(v in V_R) v."time"$ *then*
    \
    ~ ~ *continue*

    ~ $V_N <- "argmin"_(v in V_R) v."time"$

    ~ *for* $v in V_N and v."has_pending_observation"()$ *do* \
    ~ ~ OpenBox$."observe"(v."get_pending_observation"())$


    ~ *while* $V_N != emptyset and W_R != emptyset$ *do* \
    ~ ~ $v <- V_N."pop_first_by_index"()$ \
    ~ ~ $w <- W_R."pop_first_by_index"()$ \
    ~ ~ $V_R <- V_R - {v}$ \
    ~ ~ $p <- #[OpenBox]."suggest"()$ \

    ~ ~ $"simulate"(v, w, p)$
]

#pagebreak()

=== Fast safety threshold emulation

The idea behind speeding up the algorithm is that the Orchestrator can be
informed by the workers when each simulation starts, so it knows how much time
to wait before moving the safety threshold.

#algorithm[
    Fast safety threshold emulation
][
    *input*: $n$, degree of parallelism of _virtual_ cluster \
    *input*: $m$, degree of parallelism of _physical_ cluster \

    $V <- {v_1, ..., v_n}$, virtual workers \
    $W <- {w_1, ..., w_m}$, physical workers \
    $V_R <- V$, ready virtual workers \ // min heap, or something
    $W_R <- W$, ready physical workers \

    *while* computation is not interrupted *do*\
    ~ $(v, w, o, delta) <- "wait_for_result"()$ \
    ~ $v."set_pending_observation"(o)$ \
    ~ $v."time" <- v."time" + delta$ \
    ~ $V_R <- V_R union { v }$ \
    ~ $W_R <- W_R union { w }$ \

    ~ #TODO[get $v$.start_delay somehow] \
    ~ *if* $min_(v in V) v."time" + v."start_delay" < min_(v in V_R) v."time"$
    *then*
    \
    ~ ~ *continue*

    ~ $V_N <- "argmin"_(v in V_R) v."time"$

    ~ *for* $v in V_N and v."has_pending_observation"()$ *do* \
    ~ ~ OpenBox$."observe"(v."get_pending_observation"())$


    ~ *while* $V_N != emptyset and W_R != emptyset$ *do* \
    ~ ~ $v <- V_N."pop_first_by_index"()$ \
    ~ ~ $w <- W_R."pop_first_by_index"()$ \
    ~ ~ $V_R <- V_R - {v}$ \
    ~ ~ $p <- #[OpenBox]."suggest"()$ \

    ~ ~ $"simulate"(v, w, p)$
]

#pagebreak()

== Proofs

// but still possible with others (@async-computation-execution-algorithm).

// [*Algorithm 1*: Aynchronous computation execution]

// TODO: give some definitions, i.e. "smaller" cluster, "bigger cluster"

// TODO: while loop instead of "if"
// TODO: drawing with safe line moving
// == Building a PERT diagram for an asynchronous computation
// = Equivalence of state-dependent asynchronous computations

// === Incorrectness of trivial emulation <infeasibility-of-trivial-algorithm>

=== Correctness of safety threshold emulation <async-computation-execution-algorithm>

*Claim:* given two clusters with parallelism degrees $n$ and $m$ respectively,
s.t. $n > m$ the safety threshold emulation algorithm run on each of them
produces the same computation.


#page(bibliography("bibliography.bib"))

// TODO: does it support failures?

// this being the way for OpenBox.
// Different parallel algorithms require different considerations, and a realistic
// analysis is not always possible. This is the case of aynchronous optimization
// with *`OpenBox`*.


// 2. unless I'm doing something wrong, until OpenBox receives a new observation,
//     it *continues to generate the same point* _(i.e. the state of OpenBox
//     doesn't change until it receives some information about the function)_
// If $n$ workers ask for a suggestion before any of them sends an observation, the
// $n$ workers all receive the same point.
//
// This problem can be solved by adding a random $epsilon$ to each point, or
// looking for other candidates. The standalone python package of OpenBox already
// does this with the `ParallelOptimizer` @open-box-parallel-optimizer yet I still
// have to investigate why it doesn't do it with the REST API.
// #TODO[#underline(text(black)[*I was doing something wrong!*]), basically you can
//     specify a number of "initial trials", and OpenBox doesn't use a new initial
//     trial until it receives some observations; it makes sense, but I wish it was
//     documented more clearly]

// #TODO[OpenBox still needs the first point!]

// 410
// 510
// While doing some experiments with OpenBox I found out two interesting facts:
// TODO: A(n, n) si deve comportare come Trivial(n)


// v(5pt)
// v(5pt)
// \

// #TODO[give a separate definition for "computation" (like: "tasks on the same
//     core do not intersect") and "asynchronous computation", "simulation",
//     "cluster & degree of parallelism" etc...]

// @open-box-parallel-and-distributed-evaluation.
// The optimization done by OpenBox can be parallelized

// This type of computation is not "ideal", in the sense that #underline[all $n$
//     points sent in a batch have the same amount of information about the shape
//     of $f$ , so OpenBox does way more exploration than exploitation.]
//
// #TODO[the underlined statement isn't very solid, I wansn't able to come up with
//     a metric to determine that "the average quality of a suggestion is better in
//     an asynchronous computation than in a synchronous one", check
//     "simulations_1.py"]



