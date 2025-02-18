import 'dart:convert';


FoodResponse foodResponseFromJson(String str) => FoodResponse.fromJson(json.decode(str));

String foodResponseToJson(FoodResponse data) => json.encode(data.toJson());


class FoodResponse {
    List<FoodItem> results;
    int offset;
    int number;
    int totalResults;

    FoodResponse({
        required this.results,
        required this.offset,
        required this.number,
        required this.totalResults,
    });

    factory FoodResponse.fromJson(Map<String, dynamic> json) => FoodResponse(
        results: List<FoodItem>.from(json["results"].map((x) => FoodItem.fromJson(x))),
        offset: json["offset"],
        number: json["number"],
        totalResults: json["totalResults"],
    );

    Map<String, dynamic> toJson() => {
        "results": List<dynamic>.from(results.map((x) => x.toJson())),
        "offset": offset,
        "number": number,
        "totalResults": totalResults,
    };
}


class FoodItem {
    int id;
    String name;
    String image;

    FoodItem({
        required this.id,
        required this.name,
        required this.image,
    });

    factory FoodItem.fromJson(Map<String, dynamic> json) => FoodItem(
        id: json["id"],
        name: json["name"],
        image: json["image"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
    };


    String get imageUrl => "https://spoonacular.com/cdn/ingredients_500x500/$image";
}
