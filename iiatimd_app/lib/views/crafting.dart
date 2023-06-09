import 'package:flutter/material.dart';
import '../main.dart' show RecipeStorage;
import '../functions/convertNameToPath.dart';

class CraftingView extends StatefulWidget {
  const CraftingView(
      {super.key,
      required this.ingredients,
      required this.giveMainSelectedIngredients,
      required this.recipes,
      required this.storage});

  final Map ingredients;
  final Map recipes;
  final Function giveMainSelectedIngredients;
  final RecipeStorage storage;

  @override
  State<CraftingView> createState() => _CraftingViewState();
}

class _CraftingViewState extends State<CraftingView>
    with AutomaticKeepAliveClientMixin<CraftingView> {
  late double maxWidth;

  late double maxHeight;

  List chosenIngredients = [];

  List state = [];

  String potion = "";

  void craftPotion() {
    if (chosenIngredients.length == 3) {
      String effect = "";
      List effects = [];
      List checkEffects = [
        chosenIngredients[2]["effect1"],
        chosenIngredients[2]["effect2"],
        chosenIngredients[2]["effect3"],
        chosenIngredients[2]["effect4"]
      ];

      for (var i = 0; i < 2; i++) {
        effects.add([
          chosenIngredients[i]["effect1"],
          chosenIngredients[i]["effect2"],
          chosenIngredients[i]["effect3"],
          chosenIngredients[i]["effect4"]
        ]);
      }
      for (var localEffect in checkEffects) {
        if (effects[0].contains(localEffect) &&
            effects[1].contains(localEffect)) {
          debugPrint(localEffect);
          effect = localEffect;
        }
      }

      if (widget.recipes[effect] != null) {
        setState(() => potion = widget.recipes[effect]);

        widget.storage.writeRecipes(
            potion,
            chosenIngredients[0]["ingredient"],
            chosenIngredients[1]["ingredient"],
            chosenIngredients[2]["ingredient"]);
      }
    }
  }

  void onchangeState() {
    setState(() => state = chosenIngredients);
    widget.giveMainSelectedIngredients(state);
  }

  void addIngredient(Map ingredient) {
    if (chosenIngredients.length < 3 &&
        !chosenIngredients.contains(ingredient)) {
      chosenIngredients.add(ingredient);
      onchangeState();
    }
  }

  void removeIngredient(Map ingredient) {
    chosenIngredients.removeWhere((item) => item == ingredient);
    onchangeState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    maxHeight = MediaQuery.of(context).size.height;
    if (MediaQuery.of(context).size.width < 450) {
      maxWidth = MediaQuery.of(context).size.width;
    } else {
      maxWidth = MediaQuery.of(context).size.width / 3;
    }
    return Scaffold(
        body: Column(
      children: [
        SizedBox(
          height: maxHeight * 0.375,
          width: maxWidth,
          child: DecoratedBox(
            decoration: const BoxDecoration(color: Colors.black),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text(
                  "Alchemy",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                craftSlotHolder(
                  ingredientList: chosenIngredients,
                  removeFunction: removeIngredient,
                ),
                PotionImageSlot(potion: potion),
                CraftButton(craftPotion: craftPotion),
              ],
            ),
          ),
        ),
        SizedBox(
          height: maxHeight * 0.625,
          width: maxWidth,
          child: DecoratedBox(
            decoration: const BoxDecoration(color: Color(0xffE1DBBF)),
            child: FilterContainer(
              ingredients: widget.ingredients,
              chosenIngredients: chosenIngredients,
              addFunction: addIngredient,
            ),
          ),
        )
      ],
    ));
  }

  @override
  bool get wantKeepAlive => true;
}

class PotionImageSlot extends StatelessWidget {
  const PotionImageSlot({super.key, required this.potion});

  final String potion;

  @override
  Widget build(BuildContext context) {
    if (potion.isNotEmpty) {
      return Center(
          child: SizedBox(
        width: 70,
        height: 70,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: Color(0xffE1DBBF),
          ),
          child: Center(
            child: Image.asset(convertNameToPath(potion)),
          ),
        ),
      ));
    } else {
      return const Center(
        child: SizedBox(
          width: 70,
          height: 70,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xffE1DBBF),
            ),
          ),
        ),
      );
    }
  }
}

class craftSlotHolder extends StatelessWidget {
  const craftSlotHolder(
      {super.key, required this.ingredientList, required this.removeFunction});

  final ingredientList;
  final Function removeFunction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (var i = 0; i < ingredientList.length; i++)
          SelectionSlot(
            ingredient: ingredientList[i],
            removeFunction: removeFunction,
          ),
        for (var i = 0; i < 3 - ingredientList.length; i++)
          const SelectionSlotEmpty(),
      ],
    );
  }
}

class SelectionSlotEmpty extends StatelessWidget {
  const SelectionSlotEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 70,
      height: 70,
      child: DecoratedBox(
        decoration: BoxDecoration(color: Color(0xffE1DBBF)),
      ),
    );
  }
}

class SelectionSlot extends StatelessWidget {
  const SelectionSlot(
      {super.key, this.ingredient, required this.removeFunction});

  final ingredient;
  final Function removeFunction;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 70,
      child: GestureDetector(
        onTap: () {
          removeFunction(ingredient);
        }, // Image tapped
        child: DecoratedBox(
          decoration: const BoxDecoration(color: Color(0xffE1DBBF)),
          child: Center(
            child: Image.asset(convertNameToPath(ingredient["ingredient"])),
            //     Text(
            //   ingredient["ingredient"],
            //   textAlign: TextAlign.center,
            // )
          ),
        ),
      ),
    );
  }
}

class CraftButton extends StatelessWidget {
  const CraftButton({super.key, required this.craftPotion});

  final Function craftPotion;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          craftPotion();
        }, // Image tapped
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Container(
              width: 200,
              decoration: BoxDecoration(
                  color: Color(0xFF006989),
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.all(Radius.circular(7))),
              child: const Padding(
                padding: EdgeInsets.all(3.5),
                child: Text(
                  "Craft",
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              )),
        ));
  }
}

class IngredientSlot extends StatelessWidget {
  IngredientSlot(
      {super.key,
      required this.ingredient,
      required this.chosenIngredients,
      required this.addFunction});

  final Map ingredient;
  final List chosenIngredients;
  final Function addFunction;

  bool isActive = true;
  Color activeColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    if (chosenIngredients.length > 0) {
      List effectLists = [
        [
          ingredient["effect1"],
          ingredient["effect2"],
          ingredient["effect3"],
          ingredient["effect4"]
        ],
      ];
      for (Map entry in chosenIngredients) {
        effectLists.add([
          entry["effect1"],
          entry["effect2"],
          entry["effect3"],
          entry["effect4"]
        ]);
      }
      List matchingEffects = effectLists[0];
      for (var i = 1; i < effectLists.length; i++) {
        List temp = [];
        for (String effect in effectLists[i]) {
          if (matchingEffects.contains(effect)) {
            temp.add(effect);
          }
        }
        matchingEffects = temp;
      }

      if (matchingEffects.length == 0 ||
          chosenIngredients.contains(ingredient)) {
        activeColor = Colors.grey;
        isActive = false;
      }
    }

    return GestureDetector(
      onTap: () {
        if (isActive) {
          addFunction(ingredient);
        }
      }, // Image tapped
      child: DecoratedBox(
        decoration: BoxDecoration(color: activeColor),
        child: Center(
          child: Image.asset(convertNameToPath(ingredient["ingredient"])),
        ),
      ),
    );
  }
}

class Filter extends StatelessWidget {
  const Filter({super.key, required this.state, required this.onChangeState});

  final String state;
  final Function(String) onChangeState;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        FilterButton(name: "Mushrooms", onChangeState: onChangeState),
        FilterButton(name: "Plants", onChangeState: onChangeState),
        FilterButton(name: "Monsters", onChangeState: onChangeState),
        FilterButton(name: "Animals", onChangeState: onChangeState),
        FilterButton(name: "Harvestables", onChangeState: onChangeState),
      ],
    );
  }
}

class FilterButton extends StatelessWidget {
  const FilterButton(
      {super.key, required this.name, required this.onChangeState});

  final String name;
  final Function(String) onChangeState;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          onChangeState(name);
        }, // Image tapped
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Container(
              decoration: BoxDecoration(
                  color: Color(0xFF75704E),
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.all(Radius.circular(7))),
              child: Padding(
                padding: const EdgeInsets.all(3.5),
                child: Text(name, style: const TextStyle(color: Colors.white)),
              )),
        ));
  }
}

class ListChoice extends StatelessWidget {
  ListChoice(
      {super.key,
      required this.state,
      required this.ingredients,
      required this.chosenIngredients,
      required this.addFunction});

  final String state;
  final Map ingredients;
  final List chosenIngredients;

  final Function addFunction;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: GridView.count(
        padding: const EdgeInsets.all(10),
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        crossAxisCount: 4,
        childAspectRatio: (50 / 50),
        children: [
          for (int i = 0; i < ingredients[state.toLowerCase()].length; i++)
            IngredientSlot(
                ingredient: ingredients[state.toLowerCase()][i],
                chosenIngredients: chosenIngredients,
                addFunction: addFunction),
        ],
      ),
    );
  }
}

class FilterContainer extends StatefulWidget {
  const FilterContainer(
      {super.key,
      required this.ingredients,
      required this.chosenIngredients,
      required this.addFunction});

  final Map ingredients;
  final List chosenIngredients;
  final Function addFunction;

  @override
  State<FilterContainer> createState() => _FilterContainerState();
}

class _FilterContainerState extends State<FilterContainer> {
  String state = "Mushrooms";

  void onchangeState(String newState) {
    setState(() => state = newState);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Filter(state: state, onChangeState: onchangeState),
        Expanded(
          child: ListChoice(
              state: state,
              ingredients: widget.ingredients,
              chosenIngredients: widget.chosenIngredients,
              addFunction: widget.addFunction),
        )
      ],
    );
  }
}
