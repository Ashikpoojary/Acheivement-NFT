module AchievementNFT::academic_rewards {
    use std::string::String;
    use aptos_framework::signer;
    use aptos_framework::object::{Self, Object};
    use aptos_framework::account::SignerCapability;
    
    /// Struct representing an academic achievement NFT
    struct AchievementNFT has key, store {
        student_address: address,
        achievement_type: String,
        achievement_date: u64,
        grade: u64,
    }

    /// Error codes
    const INVALID_GRADE: u64 = 1;
    const UNAUTHORIZED: u64 = 2;

    /// Resource to store issuer's capabilities
    struct IssuerCapability has key {
        cap: SignerCapability,
    }

    /// Function to initialize the module and set up issuer capabilities
    public fun initialize(issuer: &signer) {
        assert!(signer::address_of(issuer) == @AchievementNFT, UNAUTHORIZED);
        let issuer_cap = IssuerCapability {
            cap: account::create_signer_cap(issuer)
        };
        move_to(issuer, issuer_cap);
    }

    /// Function to mint a new achievement NFT for a student
    public fun mint_achievement(
        issuer: &signer,
        student: address,
        achievement_type: String,
        grade: u64
    ) acquires IssuerCapability {
        // Validate issuer and grade
        assert!(signer::address_of(issuer) == @AchievementNFT, UNAUTHORIZED);
        assert!(grade <= 100, INVALID_GRADE);

        // Create new NFT
        let nft = AchievementNFT {
            student_address: student,
            achievement_type,
            achievement_date: timestamp::now_seconds(),
            grade,
        };

        // Mint and transfer NFT to student
        let constructor_ref = object::create_object(student);
        move_to(&object::generate_signer(&constructor_ref), nft);
    }
}
