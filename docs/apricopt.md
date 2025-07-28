- model
    - Model.py
        - model of a system 
            - it can be simuated
            - subject to simulation based optimization (BBO)
        - objective function (as per usual)
        - constraints
            - regular (computed via simulation)
            - fast (doesn't require a simulation, Ex?) 
        - parameters (parameter space)
            - Parameter objects
        - simulation object (road runner)
        - model instance (actual thing to simulate) (ModelInstance)

        - Finally, the object contains further information, i.e. the integration tolerances, the time step, the name of the model outputs that are actually observedand the name of the file that contains the model (if any).

    (doesn't really matter, they are set via the Model)
    - ModelInstance (it must be overriden!), AbstractBaseClass
        - basically parameters 
        - simulation configuration
        - simulation duration
        - simulation step size

    - Parameter (simple enough)
        - id
        - name
        - upper / lower bounds
        - nominal_value
        - distribution (str, name) + mu, sigma
        - granularity????

    - Observable
        - trajectory and stuff ... control systems theory

- simulation            
    - SimulationEngine.py
        - simulate (model, horizon)

