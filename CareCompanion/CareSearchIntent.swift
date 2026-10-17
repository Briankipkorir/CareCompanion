
import Foundation

// MARK: - Search Intent Model

struct CareSearchIntent {
    let service: String
    let location: String

    // Detects a service and location in a user's message.
    // This is a lightweight first version, not a full AI parser.

    static func detect(from message: String) -> CareSearchIntent? {

        let lower = message.lowercased()

        let categories: [(keywords: [String], service: String)] = [

            (
                ["hospital", "hospitals", "clinic", "clinics",
                 "doctor", "healthcare", "hospitali",
                 "hospitales", "hôpital", "医院", "مستشفى"],
                "Hospital"
            ),

            (
                ["food bank", "food pantry", "food assistance",
                 "chakula", "banco de alimentos",
                 "banque alimentaire", "食物银行"],
                "Food bank"
            ),

            (
                ["tornado", "hurricane", "evacuation",
                 "storm shelter", "emergency shelter",
                 "refugio", "abri d'urgence",
                 "makazi ya dharura", "避难所"],
                "Emergency shelter"
            ),

            (
                ["pharmacy", "pharmacist", "chemist",
                 "farmacia", "pharmacie", "duka la dawa",
                 "药店"],
                "Pharmacy"
            ),

            (
                ["pregnancy", "maternity", "prenatal",
                 "maternal care", "maternidad",
                 "maternité", "uzazi"],
                "Maternity hospital"
            ),

            (
                ["mental health", "counseling", "counselling",
                 "therapy", "therapist", "psychologist"],
                "Mental health clinic"
            ),

            (
                ["senior center", "elderly care",
                 "older adults", "wazee"],
                "Senior center"
            ),

            (
                ["homeless", "housing assistance",
                 "temporary housing", "refugee shelter"],
                "Homeless shelter"
            ),

            (
                ["shelter", "refuge", "refugio", "abri"],
                "Shelter"
            )
        ]

        guard let category = categories.first(where: { category in
            category.keywords.contains { keyword in
                lower.contains(keyword)
            }
        }) else {
            return nil
        }

        let locationMarkers = [
            " near ",
            " in ",
            " around ",
            " at ",
            " karibu na ",
            " katika ",
            " en ",
            " à ",
            " em ",
            " بالقرب من ",
            " في "
        ]

        var location = ""

        for marker in locationMarkers {

            if let range = lower.range(
                of: marker,
                options: .backwards
            ) {

                location = String(
                    message[range.upperBound...]
                )

                break
            }
        }

        location = location.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        location = location.trimmingCharacters(
            in: CharacterSet(
                charactersIn: "?.!,،。 "
            )
        )

        return CareSearchIntent(
            service: category.service,
            location: location
        )
    }
}
