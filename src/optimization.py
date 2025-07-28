from apricopt.model.Model import Model
from apricopt.model.Observable import Observable
from apricopt.model.Parameter import Parameter
from apricopt.simulation.roadrunner.RoadRunnerEngine import RoadRunnerEngine
from apricopt.solving.blackbox.BlackBox import BlackBox

import random

import model

# TODO: simulate until equilibrium
# TODO: parallelize on cluster


class BlackBoxSBML(BlackBox):
    def __init__(self, parameters: set[model.PhysicalEntityStandardId]) -> None:
        self.rr = RoadRunnerEngine()
        self.rr_model: Model = Model(
            sim_engine=self.rr,
            model_filename='test.sbml',
            abs_tol=1.0,
            rel_tol=1.0,
            time_step=1.0,
        )

        self.rr_model.objective = Observable('output', 'output', ['output'])

        self.rr_model.set_parameter_space(
            {
                Parameter(
                    str(stId),
                    str(stId),
                    lower_bound=-300.0,
                    upper_bound=300.0,
                    nominal_value=0.0,
                )
                for stId in parameters
            }
        )

    def evaluate(
        self, parameters: dict[str, float], check_input=True
    ) -> dict[str, float]:
        result = self.rr.simulate(self.rr_model, 10000)
        print(result)
        return result

    def evaluate_and_set_state(self, parameters: dict[str, float]) -> dict[str, float]:
        return parameters

    def evaluate_np_array(self, parameters, check_input=False) -> dict[str, float]:
        return super().evaluate_np_array(parameters, check_input)

    def evaluate_objective_np_array(self, parameters, check_input=False) -> float:
        return super().evaluate_objective_np_array(parameters, check_input)

    def is_input_valid(self, parameters: dict[str, float]) -> bool:
        return super().is_input_valid(parameters)

    def get_optimization_parameters_lower_bounds_nparray(self):
        return super().get_optimization_parameters_lower_bounds_nparray()

    def get_optimization_parameters_upper_bounds_nparray(self):
        return super().get_optimization_parameters_upper_bounds_nparray()

    def optimization_parameters_initial_values_are_empty(self) -> bool:
        return False

    def granularity_is_required(self) -> bool:
        return False

    def set_granularity_is_required(self, is_required: bool) -> None:
        return super().set_granularity_is_required(is_required)

    def set_fixed_parameters(self, params: dict[str, float]) -> None:
        pass

    def set_optimization_parameters(self, params: dict[str, float]) -> None:
        pass

    def get_optimization_parameters_number(self) -> int:
        # return 1
        return len(self.rr_model.parameters)
        # return len(self.parameters)

    def get_optimization_parameters_ids(self) -> list[str]:
        return sorted(list(self.rr_model.parameters.keys()))

    def get_optimization_parameter_lower_bound(self, param_id) -> float:
        return 1

    def get_optimization_parameter_upper_bound(self, param_id) -> float:
        return 600

    def get_optimization_parameter_initial_value(self, param_id) -> float:
        return random.randint(1, 600)

    def get_optimization_parameter_granularity(self, param_id) -> float:
        return self.rr_model.parameters[param_id].granularity

    def get_extreme_barrier_constraints_number(self) -> int:
        return 0

    def get_progressive_barrier_constraints_number(self) -> int:
        return 0

    def get_extreme_barrier_constraints_ids(self) -> list[str]:
        return []

    def get_progressive_barrier_constraints_ids(self) -> list[str]:
        return []

    def get_objective_id(self) -> str:
        return 'output'

    def get_objective_upper_bound(self):
        return float('Inf')

    @staticmethod
    def get_raisable_exception_type():
        return ValueError

    def set_optimization_parameters_initial_values(
        self, param_values: dict[str, float]
    ) -> None:
        pass

    def finalize(self) -> None:
        pass


# return super().evaluate(parameters, check_input)


#     """
# Implements the Griewank Function, as shown in https://www.sfu.ca/~ssurjano/griewank.html
# :param parameters:
# :return:
# """
# if len(parameters) != self.d:
#     raise ValueError
#
# xx = []
# for i in range(self.d):
#     xx.append(parameters[str(i)])
# s = 0
# p = 1
# for ii in range(self.d):
#     xi = xx[ii]
#     s += xi ** 2 / 4000
#     p *= math.cos(xi / math.sqrt(ii + 1))
#
# result = s - p + 1
# div7 = result % 7.0
# div6 = result % 6.0
#
# return {"result": result,
#         "dummy_extreme_constraint": -div7 if div7 > 0 else 1,
#         "dummy_progressive_constraint": -div6 if div6 > 0 else 1}
#

# def evaluate_and_set_state(self, parameters: Dict[str, float]) -> Dict[str, float]:
#     pass
#
# def set_fixed_parameters(self, params: Dict[str, float]) -> None:
#     pass
#
# def set_optimization_parameters(self, params: Dict[str, float]) -> None:
#     pass
#
# def get_optimization_parameters_number(self) -> int:
#     return self.d
#
# def get_optimization_parameters_ids(self) -> List[str]:
#     return [str(i) for i in range(self.d)]
#
# def get_optimization_parameter_lower_bound(self, param_id) -> float:
#     return -600
#
# def get_optimization_parameter_upper_bound(self, param_id) -> float:
#     return 600
#
# def get_optimization_parameter_initial_value(self, param_id) -> float:
#     return random.randint(-600, 600)
#
# def get_optimization_parameter_granularity(self, param_id) -> float:
#     return 0
#
# def get_extreme_barrier_constraints_number(self) -> int:
#     return 1
#
# def get_progressive_barrier_constraints_number(self) -> int:
#     return 1
#
# def get_extreme_barrier_constraints_ids(self) -> List[str]:
#     return ["dummy_extreme_constraint"]
#
# def get_progressive_barrier_constraints_ids(self) -> List[str]:
#     return ["dummy_progressive_constraint"]
#
# def get_objective_id(self) -> str:
#     return "result"
#
# def get_objective_upper_bound(self):
#     return float('Inf')
#
# @staticmethod
# def get_raisable_exception_type():
#     return ValueError
#
# def set_optimization_parameters_initial_values(self, param_values: Dict[str, float]) -> None:
#     pass
#
# def finalize(self) -> None:
#     pass

# param_values = {str(stId): 0.0 for stId in parameters}
# self.rr_model.set_params(params_values=param_values)

# self.sim_engine = sim_engine
# self.model = Model(sim_engine, "", 0, 0, 1, observed_outputs=["output"])
# self.model.objective = Observable("output", "output", ["output"])
# parameter = Parameter("parameter", "parameter", lower_bound=0, upper_bound=1, nominal_value=0.5)
# self.model.set_parameter_space({parameter})
# self.horizon = 1
# super().__init__()

# if check_input:
#     pass
# return {'result': sum(parameters.values())}
