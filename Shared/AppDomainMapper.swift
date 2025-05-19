import Foundation

// JSON 데이터 구조 정의
struct Mapping: Codable {
    let id: String
    let hosts: [String]
    let bundle: String
    
    enum CodingKeys: String, CodingKey {
        case id, hosts, bundle
    }
}

struct Mappings: Codable {
    let mappings: [Mapping]
}

/// 앱과 도메인 간의 매핑을 관리하는 유틸리티 클래스
public class AppDomainMapper {
    public static let shared = AppDomainMapper()
    
    // 도메인 → 식별자 매핑
    private var domainToId: [String: String]
    
    // 번들 ID → 식별자 매핑
    private var bundleToId: [String: String]
    
    // 식별자 → 도메인 리스트 매핑
    private var idToDomains: [String: [String]]
    
    // 식별자 → 번들 ID 매핑
    private var idToBundle: [String: String]
    
    // App Group의 UserDefaults
    private let sharedDefaults: UserDefaults?
    
    // UserDefaults 키
    private let mappingsKey = "AppDomainMapper_Mappings"
    
    private init() {
        // App Group의 UserDefaults 초기화
        self.sharedDefaults = UserDefaults(suiteName: "group.io.cru31.SimplyLock")
        
        // 초기화: 기본 매핑 설정
        self.domainToId = [:]
        self.bundleToId = [:]
        self.idToDomains = [:]
        self.idToBundle = [:]
        
        // 매핑 데이터 로드
        if !loadMappingsFromUserDefaults() {
            // UserDefaults에 데이터가 없으면 JSON 파일에서 로드
            loadMappingsFromJSON()
            // UserDefaults에 저장
            saveMappingsToUserDefaults()
        }
    }
    
    // MARK: - UserDefaults 저장/로드
    
    private func saveMappingsToUserDefaults() {
        let mappings = Mappings(mappings: self.mappings)
        if let data = try? JSONEncoder().encode(mappings) {
            sharedDefaults?.set(data, forKey: mappingsKey)
            sharedDefaults?.synchronize()
        }
    }
    
    private func loadMappingsFromUserDefaults() -> Bool {
        guard let data = sharedDefaults?.data(forKey: mappingsKey),
              let mappings = try? JSONDecoder().decode(Mappings.self, from: data) else {
            return false
        }
        self.mappings = mappings.mappings
        initializeMappings()
        return true
    }
    
    // MARK: - JSON 로드
    
    private var mappings: [Mapping] = []
    
    private func loadMappingsFromJSON() {
        guard let url = Bundle.main.url(forResource: "BundleHostsMappings", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONDecoder().decode(Mappings.self, from: data) else {
            print("Failed to load mappings.json")
            return
        }
        self.mappings = json.mappings
        initializeMappings()
    }
    
    private func initializeMappings() {
        // 매핑 초기화
        for mapping in mappings {
            let identifier = mapping.id
            let bundleID = mapping.bundle
            let domains = mapping.hosts
            
            // idToBundle
            idToBundle[identifier] = bundleID
            
            // idToDomains
            idToDomains[identifier] = domains
            
            // bundleToId
            bundleToId[bundleID] = identifier
            
            // domainToId
            for domain in domains {
                domainToId[normalizeDomain(domain)] = identifier
            }
        }
    }
    
    // MARK: - 매핑 조회 메서드
    
    /// 도메인을 기반으로 식별자 반환
    public func getIdentifierForDomain(_ domain: String) -> String? {
        let normalizedDomain = normalizeDomain(domain)
        return domainToId[normalizedDomain]
    }
    
    /// 번들 ID를 기반으로 식별자 반환
    public func getIdentifierForBundleID(_ bundleID: String) -> String? {
        return bundleToId[bundleID]
    }
    
    /// 번들 ID를 기반으로 관련 도메인 리스트 반환
    public func getDomainsForBundleID(_ bundleID: String) -> [String] {
        guard let identifier = getIdentifierForBundleID(bundleID) else {
            return []
        }
        return idToDomains[identifier] ?? []
    }
    
    /// 도메인을 기반으로 관련 번들 ID 반환
    public func getBundleIDForDomain(_ domain: String) -> String? {
        guard let identifier = getIdentifierForDomain(domain) else {
            return nil
        }
        return idToBundle[identifier]
    }
    
    /// 도메인을 기반으로 정규화된 도메인 반환
    public func getCanonicalDomain(_ domain: String) -> String {
        let normalizedDomain = normalizeDomain(domain)
        return normalizedDomain
    }
    
    // MARK: - 매핑 관리 메서드
    
    /// 새로운 매핑 추가
    public func addMapping(bundleID: String, identifier: String, domains: [String]) {
        let normalizedDomains = domains.map(normalizeDomain)
        
        // 매핑 업데이트
        mappings.append(Mapping(id: identifier, hosts: normalizedDomains, bundle: bundleID))
        idToBundle[identifier] = bundleID
        idToDomains[identifier] = normalizedDomains
        bundleToId[bundleID] = identifier
        
        for domain in normalizedDomains {
            domainToId[domain] = identifier
        }
        
        // UserDefaults에 저장
        saveMappingsToUserDefaults()
    }
    
    /// 매핑 제거
    public func removeMapping(bundleID: String) {
        guard let identifier = getIdentifierForBundleID(bundleID) else { return }
        
        // 매핑 제거
        if let domains = idToDomains[identifier] {
            for domain in domains {
                domainToId.removeValue(forKey: domain)
            }
        }
        idToDomains.removeValue(forKey: identifier)
        idToBundle.removeValue(forKey: identifier)
        bundleToId.removeValue(forKey: bundleID)
        mappings.removeAll { $0.id == identifier }
        
        // UserDefaults에 저장
        saveMappingsToUserDefaults()
    }
    
    /// 도메인 → 번들 ID 매핑 제거
    public func removeMapping(domain: String) {
        let normalizedDomain = normalizeDomain(domain)
        guard let identifier = domainToId[normalizedDomain],
              let bundleID = idToBundle[identifier] else { return }
        
        // 도메인 제거
        if var domains = idToDomains[identifier] {
            domains.removeAll { $0 == normalizedDomain }
            domainToId.removeValue(forKey: normalizedDomain)
            
            if domains.isEmpty {
                idToDomains.removeValue(forKey: identifier)
                idToBundle.removeValue(forKey: identifier)
                bundleToId.removeValue(forKey: bundleID)
                mappings.removeAll { $0.id == identifier }
            } else {
                idToDomains[identifier] = domains
                mappings = mappings.map { mapping in
                    if mapping.id == identifier {
                        return Mapping(id: mapping.id, hosts: domains, bundle: bundleID)
                    }
                    return mapping
                }
            }
            
            // UserDefaults에 저장
            saveMappingsToUserDefaults()
        }
    }
    
    // MARK: - 유틸리티
    
    /// 도메인 정규화 (프로토콜, 경로 제거 및 서브도메인 처리)
    private func normalizeDomain(_ domain: String) -> String {
        // 1. 프로토콜 및 경로 제거
        var domainString = domain.lowercased()
        
        // URL 형식인지 확인
        if domainString.hasPrefix("http://") {
            domainString = String(domainString.dropFirst(7))
        } else if domainString.hasPrefix("https://") {
            domainString = String(domainString.dropFirst(8))
        }
        
        // 경로 및 쿼리 제거
        if let pathIndex = domainString.firstIndex(of: "/") {
            domainString = String(domainString[..<pathIndex])
        }
        if let queryIndex = domainString.firstIndex(of: "?") {
            domainString = String(domainString[..<queryIndex])
        }
        
        // 2. URL 객체로 파싱하여 호스트 추출
        if let url = URL(string: "https://\(domainString)"), let host = url.host {
            domainString = host
        }
        
        // 3. 일반적인 서브도메인 제거 (예: www., m.)
        let commonSubdomains = ["www.", "m.", "mobile."]
        for subdomain in commonSubdomains {
            if domainString.hasPrefix(subdomain) {
                domainString = String(domainString.dropFirst(subdomain.count))
                break
            }
        }
        
        return domainString
    }
}
