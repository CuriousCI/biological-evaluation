from typing import TypeAlias
from collections import UserString

# StandardId: TypeAlias = str


class StandardId(UserString):
    def __init__(self, value) -> None:
        super().__init__(value.replace('-', '_'))


PhysicalEntityStandardId: TypeAlias = StandardId


class RationalGT0(float):
    def __init__(self, value) -> None:
        if value <= 0:
            raise TypeError('Only reals > 0 allowed')
        float.__init__(value)


class PhysicalEntity:
    def __init__(self, standard_id: StandardId, display_name: str) -> None:
        self.standard_id = standard_id
        self.display_name = display_name

    def __hash__(self) -> int:
        return self.standard_id.__hash__()

    def __eq__(self, value: object, /) -> bool:
        return 'standard_id' in value.__dict__ and self.standard_id.__eq__(
            value.__dict__['standard_id']
        )

    def __repr__(self) -> str:
        return f'{self.standard_id}'


class PhysicalEntityInReaction(PhysicalEntity):
    def __init__(
        self, standard_id: StandardId, display_name: str, stoichiometry: RationalGT0
    ) -> None:
        super().__init__(standard_id, display_name)
        self.stoichiometry = stoichiometry


Reactant: TypeAlias = PhysicalEntityInReaction
ReactionProduct: TypeAlias = PhysicalEntityInReaction


class ReactionLikeEvent:
    def __init__(
        self, reactants: set[Reactant], products: set[ReactionProduct]
    ) -> None:
        self.reactants = reactants
        self.products = products


SBMLDocumentString: TypeAlias = str
