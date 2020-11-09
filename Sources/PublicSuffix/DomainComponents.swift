import Foundation

/// The components of a domain.
public struct DomainComponents {
    /// The top-level domain (public suffix).
    public let tld: String
    /// The second-level domain (first part to the left of the TLD).
    public let sld: String
    /// The domain (SLD and TLD).
    public let domain: String
    /// The subdomain (parts to the left of the SLD).
    public let subdomain: String?
    /// Whether the domain has a known TLD. An unknown TLD may indicate that the TLD is invalid or hasn't been added to
    /// the list yet.
    public let hasKnownTLD: Bool
}
