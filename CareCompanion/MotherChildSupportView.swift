
import SwiftUI

struct MotherChildSupportView: View {

    @ObservedObject private var locationManager =
        CareLocationManager.shared

    private let teal = Color.teal

    var body: some View {

        ScrollView {

            VStack(alignment: .leading, spacing: 20) {

                header

                Text("Pregnancy & Healthcare")
                    .font(.title3.bold())

                supportLink(
                    "Affordable Prenatal Care",
                    subtitle: "Clinics for pregnancy checkups",
                    icon: "heart.text.square.fill",
                    query: "Low cost prenatal care clinic"
                )

                supportLink(
                    "Maternity Hospitals",
                    subtitle: "Pregnancy and delivery services",
                    icon: "cross.case.fill",
                    query: "Maternity hospital"
                )

                supportLink(
                    "Community Health Centers",
                    subtitle: "Ask about sliding-scale fees",
                    icon: "stethoscope",
                    query: "Community health center"
                )

                Text("Food & Baby Essentials")
                    .font(.title3.bold())

                supportLink(
                    "WIC Offices",
                    subtitle: "Food and nutrition support",
                    icon: "heart.fill",
                    query: "WIC office"
                )

                supportLink(
                    "Food Banks",
                    subtitle: "Groceries for families",
                    icon: "basket.fill",
                    query: "Food bank"
                )

                supportLink(
                    "Baby Supplies",
                    subtitle: "Diapers, formula and baby essentials",
                    icon: "shippingbox.fill",
                    query: "Diaper bank baby supplies assistance"
                )

                supportLink(
                    "Family Support Centers",
                    subtitle: "Community programs for parents",
                    icon: "person.3.fill",
                    query: "Family resource center"
                )

                Text("Child Development")
                    .font(.title3.bold())

                supportLink(
                    "Early Childhood Programs",
                    subtitle: "Early Head Start and Head Start",
                    icon: "book.fill",
                    query: "Head Start center"
                )

                Text("Official U.S. Assistance Programs")
                    .font(.title3.bold())

                officialLink(
                    "Find WIC Assistance",
                    subtitle: "Food and nutrition support for eligible families",
                    url: "https://www.fna.usda.gov/wic/locator"
                )

                officialLink(
                    "Apply for SNAP",
                    subtitle: "Find your state's food benefits office",
                    url: "https://www.fna.usda.gov/snap/state-directory"
                )

                officialLink(
                    "Find Affordable Healthcare",
                    subtitle: "U.S. community health centers",
                    url: "https://findahealthcenter.hrsa.gov/"
                )

                Text(
                    "Program eligibility, costs, availability and approved foods vary. Contact the provider or official agency to confirm. Map listings are not proof that assistance is available."
                )
                .font(.footnote)
                .foregroundStyle(.secondary)

                Text(
                    "If someone is experiencing a pregnancy-related medical emergency, seek immediate emergency medical care."
                )
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Mother & Child Support")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if !locationManager.hasLocation {
                await locationManager.loadProfile()
            }
        }
    }

    private var header: some View {

        VStack(alignment: .leading, spacing: 12) {

            Image(systemName: "figure.2.and.child.holdinghands")
                .font(.system(size: 42))
                .foregroundStyle(teal)

            Text("Support for Every Family")
                .font(.title.bold())

            Text(
                "Find pregnancy care, food assistance, baby supplies and services for children."
            )
            .foregroundStyle(.secondary)

            if locationManager.hasLocation {

                Label(
                    locationManager.locationText,
                    systemImage: "location.fill"
                )
                .font(.subheadline)
                .foregroundStyle(teal)
            }
        }
    }

    private func supportLink(
        _ title: String,
        subtitle: String,
        icon: String,
        query: String
    ) -> some View {

        NavigationLink {

            CareMapView(initialQuery: query)

        } label: {

            HStack(spacing: 14) {

                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(teal)
                    .frame(width: 46, height: 46)
                    .background(teal.opacity(0.12))
                    .clipShape(
                        RoundedRectangle(cornerRadius: 12)
                    )

                VStack(alignment: .leading, spacing: 4) {

                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(
                Color(.secondarySystemGroupedBackground)
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 16)
            )
        }
        .buttonStyle(.plain)
    }

    private func officialLink(
        _ title: String,
        subtitle: String,
        url: String
    ) -> some View {

        Link(destination: URL(string: url)!) {

            HStack(spacing: 12) {

                Image(systemName: "checkmark.shield.fill")
                    .foregroundStyle(teal)

                VStack(alignment: .leading, spacing: 4) {

                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "arrow.up.right.square")
                    .foregroundStyle(teal)
            }
            .padding()
            .background(
                Color(.secondarySystemGroupedBackground)
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 16)
            )
        }
    }
}

#Preview {
    NavigationStack {
        MotherChildSupportView()
    }
}
