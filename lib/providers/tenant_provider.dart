import 'package:flutter_riverpod/flutter_riverpod.dart';

class Tenant {
  final String id;
  final String name;
  final String slug;
  final String? tenantCode;
  final String? parentTenantId;
  final String? parentName;
  final String organizationType; // 'central' or 'branch'
  final String? description;
  final String? logoUrl;
  final String? website;
  final String? location;
  final String? phone;
  final String? email;
  final String plan;
  final String status;
  final int maxUsers;
  final int maxStorageMB;
  final Map<String, dynamic>? settings;
  final DateTime createdAt;
  final DateTime? expiryDate;
  final String? ownerEmail;
  final String? contactPhone;
  final bool isActive;
  // Computed fields
  final int? activeUsersCount;
  final int? totalStudentsCount;
  final int? totalBranchesCount; // Only for central orgs

  Tenant({
    required this.id,
    required this.name,
    required this.slug,
    this.tenantCode,
    this.parentTenantId,
    this.parentName,
    this.organizationType = 'branch',
    this.description,
    this.logoUrl,
    this.website,
    this.location,
    this.phone,
    this.email,
    this.plan = 'standard',
    this.status = 'active',
    this.maxUsers = 100,
    this.maxStorageMB = 1024,
    this.settings,
    required this.createdAt,
    this.expiryDate,
    this.ownerEmail,
    this.contactPhone,
    this.isActive = true,
    this.activeUsersCount,
    this.totalStudentsCount,
    this.totalBranchesCount,
  });

  bool get isCentral => organizationType == 'central';
  bool get isBranch => organizationType == 'branch';
  bool get hasParent => parentTenantId != null;

  Tenant copyWith({
    String? id,
    String? name,
    String? slug,
    String? tenantCode,
    String? parentTenantId,
    String? parentName,
    String? organizationType,
    String? description,
    String? logoUrl,
    String? website,
    String? location,
    String? phone,
    String? email,
    String? plan,
    String? status,
    int? maxUsers,
    int? maxStorageMB,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
    DateTime? expiryDate,
    String? ownerEmail,
    String? contactPhone,
    bool? isActive,
    int? activeUsersCount,
    int? totalStudentsCount,
    int? totalBranchesCount,
  }) {
    return Tenant(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      tenantCode: tenantCode ?? this.tenantCode,
      parentTenantId: parentTenantId ?? this.parentTenantId,
      parentName: parentName ?? this.parentName,
      organizationType: organizationType ?? this.organizationType,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      website: website ?? this.website,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      plan: plan ?? this.plan,
      status: status ?? this.status,
      maxUsers: maxUsers ?? this.maxUsers,
      maxStorageMB: maxStorageMB ?? this.maxStorageMB,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      expiryDate: expiryDate ?? this.expiryDate,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      isActive: isActive ?? this.isActive,
      activeUsersCount: activeUsersCount ?? this.activeUsersCount,
      totalStudentsCount: totalStudentsCount ?? this.totalStudentsCount,
      totalBranchesCount: totalBranchesCount ?? this.totalBranchesCount,
    );
  }
}

class TenantNotifier extends StateNotifier<List<Tenant>> {
  TenantNotifier()
      : super([
          // Central Organization
          Tenant(
            id: '00000000-0000-0000-0000-000000000001',
            name: 'International Education Group',
            slug: 'ieg-central',
            tenantCode: 'C0001',
            organizationType: 'central',
            description:
                'Main central organization managing all branch schools',
            plan: 'enterprise',
            maxUsers: 1000,
            maxStorageMB: 10240,
            createdAt: DateTime.now().subtract(const Duration(days: 365)),
            ownerEmail: 'admin@ieg.edu',
            contactPhone: '+1-555-0100',
            totalBranchesCount: 4,
            isActive: true,
          ),
          // Branch 1
          Tenant(
            id: 'OX-2025',
            name: 'Oxford Academy',
            slug: 'oxford-academy',
            tenantCode: 'B0001',
            parentTenantId: '00000000-0000-0000-0000-000000000001',
            parentName: 'International Education Group',
            organizationType: 'branch',
            location: 'London, UK',
            plan: 'Premium',
            maxUsers: 200,
            createdAt: DateTime.now().subtract(const Duration(days: 30)),
            expiryDate: DateTime.now().add(const Duration(days: 335)),
            ownerEmail: 'oxford@emis.com',
            contactPhone: '+44-20-1234-5678',
            activeUsersCount: 156,
            totalStudentsCount: 1200,
            isActive: true,
          ),
          // Branch 2
          Tenant(
            id: 'FS-2025',
            name: 'Future Scholars',
            slug: 'future-scholars',
            tenantCode: 'B0002',
            parentTenantId: '00000000-0000-0000-0000-000000000001',
            parentName: 'International Education Group',
            organizationType: 'branch',
            location: 'New York, USA',
            plan: 'Standard',
            maxUsers: 150,
            createdAt: DateTime.now().subtract(const Duration(days: 15)),
            expiryDate: DateTime.now().add(const Duration(days: 350)),
            ownerEmail: 'future@emis.com',
            contactPhone: '+1-212-555-0199',
            activeUsersCount: 98,
            totalStudentsCount: 850,
            isActive: true,
          ),
          // Branch 3
          Tenant(
            id: 'GI-2025',
            name: 'Global Institute',
            slug: 'global-institute',
            tenantCode: 'B0003',
            parentTenantId: '00000000-0000-0000-0000-000000000001',
            parentName: 'International Education Group',
            organizationType: 'branch',
            location: 'Dubai, UAE',
            plan: 'Enterprise',
            maxUsers: 300,
            createdAt: DateTime.now().subtract(const Duration(days: 60)),
            expiryDate: DateTime.now().add(const Duration(days: 305)),
            ownerEmail: 'global@emis.com',
            contactPhone: '+971-4-123-4567',
            activeUsersCount: 245,
            totalStudentsCount: 1500,
            isActive: true,
          ),
          // Branch 4
          Tenant(
            id: 'KLC-2025',
            name: 'Kabul Language Center',
            slug: 'kabul-language-center',
            tenantCode: 'B0004',
            parentTenantId: '00000000-0000-0000-0000-000000000001',
            parentName: 'International Education Group',
            organizationType: 'branch',
            location: 'Kabul, AF',
            plan: 'Standard',
            maxUsers: 100,
            createdAt: DateTime.now().subtract(const Duration(days: 45)),
            expiryDate: DateTime.now().add(const Duration(days: 320)),
            ownerEmail: 'kabul@emis.com',
            contactPhone: '+93-20-123-4567',
            activeUsersCount: 67,
            totalStudentsCount: 450,
            isActive: true,
          ),
        ]);

  // Get all central organizations
  List<Tenant> getCentralOrganizations() {
    return state.where((t) => t.isCentral).toList();
  }

  // Get all branches
  List<Tenant> getAllBranches() {
    return state.where((t) => t.isBranch).toList();
  }

  // Get branches for a specific central organization
  List<Tenant> getBranchesForCentral(String centralId) {
    return state
        .where((t) => t.isBranch && t.parentTenantId == centralId)
        .toList();
  }

  // Get central organization for a branch
  Tenant? getCentralForBranch(String branchId) {
    final branch = state.firstWhere(
      (t) => t.id == branchId,
      orElse: () => throw Exception('Branch not found'),
    );

    if (branch.parentTenantId == null) return null;

    return state.firstWhere(
      (t) => t.id == branch.parentTenantId,
      orElse: () => throw Exception('Central organization not found'),
    );
  }

  void addTenant(Tenant tenant) {
    state = [...state, tenant];
  }

  void updateTenant(Tenant tenant) {
    state = [
      for (final t in state)
        if (t.id == tenant.id) tenant else t
    ];
  }

  void deleteTenant(String id) {
    state = state.where((t) => t.id != id).toList();
  }
}

final tenantProvider =
    StateNotifierProvider<TenantNotifier, List<Tenant>>((ref) {
  return TenantNotifier();
});

final currentTenantProvider = StateProvider<Tenant?>((ref) {
  final tenants = ref.watch(tenantProvider);
  return tenants.isNotEmpty ? tenants.first : null;
});
