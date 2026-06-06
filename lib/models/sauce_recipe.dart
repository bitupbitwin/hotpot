class SauceRecipe {
  final String id;
  final String name;
  final String tag;
  final String description;
  final List<String> ingredients;
  final bool isCustom;

  const SauceRecipe({
    required this.id,
    required this.name,
    required this.tag,
    required this.description,
    required this.ingredients,
    this.isCustom = false,
  });
}
