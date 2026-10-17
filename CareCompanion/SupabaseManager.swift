
import Foundation
import Supabase

enum SupabaseManager {
    static let client = SupabaseClient(
        supabaseURL: URL(
            string: "https://nxvzljiruujjbcljnsby.supabase.co"
        )!,
        supabaseKey: "sb_publishable_qHl8VhK06upR1x4qRIlarQ_yVHTTGbP"
    )
}
