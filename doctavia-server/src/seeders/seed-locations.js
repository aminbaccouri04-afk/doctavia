'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    const now = new Date();
    const locationsData = [
      { address: '123 Rue de la Liberté', city: 'Tunis', latitude: 36.8065, longitude: 10.1815, created_at: now, updated_at: now },
      { address: '45 Ave Habib Bourguiba', city: 'Sousse', latitude: 35.8256, longitude: 10.6369, created_at: now, updated_at: now },
      { address: '78 Route de Teniour', city: 'Sfax', latitude: 34.7406, longitude: 10.7603, created_at: now, updated_at: now },
      { address: '10 Rue de l\'Indépendance', city: 'Bizerte', latitude: 37.2744, longitude: 9.8739, created_at: now, updated_at: now },
      { address: '22 Boulevard de l\'Environnement', city: 'Nabeul', latitude: 36.4561, longitude: 10.7376, created_at: now, updated_at: now },
      { address: '56 Rue des Jasmins', city: 'Monastir', latitude: 35.7780, longitude: 10.8262, created_at: now, updated_at: now },
    ];
    await queryInterface.bulkInsert('locations', locationsData);
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.bulkDelete('locations', null, {});
  }
};
