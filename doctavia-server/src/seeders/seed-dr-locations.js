'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    const [doctors] = await queryInterface.sequelize.query('SELECT d.id, u.email FROM doctors d JOIN users u ON d.user_id = u.id ORDER BY u.email ASC');
    const [locations] = await queryInterface.sequelize.query('SELECT id FROM locations ORDER BY address ASC');
    
    const drLocData = [];
    
    for (let i = 0; i < doctors.length; i++) {
      const doc = doctors[i];
      const loc1 = locations[i % locations.length];
      if (loc1) drLocData.push({ doctor_id: doc.id, location_id: loc1.id });
      
      if (i % 3 === 0) {
        const loc2 = locations[(i + 2) % locations.length];
        if (loc2) drLocData.push({ doctor_id: doc.id, location_id: loc2.id });
      }
    }
    
    await queryInterface.bulkInsert('dr_locations', drLocData);
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.bulkDelete('dr_locations', null, {});
  }
};
