class Permissions {
  bool createMachines;
  bool fixMachineStock;
  bool editMachines;
  bool deleteMachines;

  bool createProducts;
  bool editProducts;
  bool deleteProducts;

  bool createCategories;
  bool editCategories;
  bool deleteCategories;

  bool createRoutes;
  bool editRoutes;
  bool deleteRoutes;

  bool createGroups;
  bool editGroups;
  bool deleteGroups;

  bool listOperators;
  bool createOperators;
  bool listManagers;
  bool createManagers;

  bool createPointsOfSale;
  bool editPointsOfSale;
  bool deletePointsOfSale;

  bool toggleMaintenanceMode;
  bool addRemoteCredit;
  bool generateReports;

  //for operators alone
  bool editCollections;
  bool deleteCollections;

  Permissions.forOperator() {
    editMachines = false;
    deleteMachines = false;
    toggleMaintenanceMode = false;
    addRemoteCredit = false;
    editCollections = false;
    deleteCollections = false;
    fixMachineStock = false;
  }

  Permissions.forManager() {
    createMachines = false;
    editMachines = false;
    deleteMachines = false;
    fixMachineStock = false;
    createProducts = false;
    editProducts = false;
    deleteProducts = false;
    createCategories = false;
    editCategories = false;
    deleteCategories = false;
    createGroups = false;
    editGroups = false;
    deleteGroups = false;
    listOperators = false;
    createOperators = false;
    listManagers = false;
    createManagers = false;
    createPointsOfSale = false;
    editPointsOfSale = false;
    deletePointsOfSale = false;
    toggleMaintenanceMode = false;
    addRemoteCredit = false;
    generateReports = false;
    createRoutes = false;
    editRoutes = false;
    deleteRoutes = false;
    editCollections = true;
    deleteCollections = true;
  }

  Permissions.forOwner() {
    createMachines = true;
    editMachines = true;
    deleteMachines = true;
    fixMachineStock = true;
    createProducts = true;
    editProducts = true;
    deleteProducts = true;
    createCategories = true;
    editCategories = true;
    deleteCategories = true;
    createGroups = true;
    editGroups = true;
    deleteGroups = true;
    listOperators = true;
    createOperators = true;
    listManagers = true;
    createManagers = true;
    createPointsOfSale = true;
    editPointsOfSale = true;
    deletePointsOfSale = true;
    toggleMaintenanceMode = true;
    addRemoteCredit = true;
    generateReports = true;
    editCollections = true;
    deleteCollections = true;
    createRoutes = true;
    editRoutes = true;
    deleteRoutes = true;
  }

  Permissions.fromJson(Map<String, dynamic> json, String role) {
    createMachines = json['createMachines'] ?? false;
    editMachines = json['editMachines'] ?? false;
    deleteMachines = json['deleteMachines'] ?? false;
    fixMachineStock = json['fixMachineStock'] ?? false;
    createProducts = json['createProducts'] ?? false;
    editProducts = json['editProducts'] ?? false;
    deleteProducts = json['deleteProducts'] ?? false;
    createCategories = json['createCategories'] ?? false;
    editCategories = json['editCategories'] ?? false;
    deleteCategories = json['deleteCategories'] ?? false;
    createGroups = json['createGroups'] ?? false;
    editGroups = json['editGroups'] ?? false;
    deleteGroups = json['deleteGroups'] ?? false;
    listOperators = json['listOperators'] ?? false;
    createOperators = json['createOperators'] ?? false;
    listManagers = json['listManagers'] ?? false;
    createManagers = json['createManagers'] ?? false;
    createPointsOfSale = json['createPointsOfSale'] ?? false;
    editPointsOfSale = json['editPointsOfSale'] ?? false;
    deletePointsOfSale = json['deletePointsOfSale'] ?? false;
    toggleMaintenanceMode = json['toggleMaintenanceMode'] ?? false;
    addRemoteCredit = json['addRemoteCredit'] ?? false;
    generateReports = json['generateReports'] ?? false;
    editCollections = json['editCollections'] ?? false;
    deleteCollections = json['deleteCollections'] ?? false;
    createRoutes = json['createRoutes'] ?? false;
    editRoutes = json['editRoutes'] ?? false;
    deleteRoutes = json['deleteRoutes'] ?? false;
    if (role == 'MANAGER') {
      editCollections = true;
      deleteCollections = true;
    }
  }
}
