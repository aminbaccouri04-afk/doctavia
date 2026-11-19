'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    const now = new Date();
    const [patients] = await queryInterface.sequelize.query("SELECT id, email FROM users WHERE role = 'patient' ORDER BY email ASC");
    const [doctors] = await queryInterface.sequelize.query('SELECT d.id, u.email FROM doctors d JOIN users u ON d.user_id = u.id ORDER BY u.email ASC');
    
    const favData = [];
    for (let i = 0; i < patients.length; i++) {
      const favDoc = doctors[i % doctors.length];
      if (favDoc) {
        favData.push({ user_id: patients[i].id, doctor_id: favDoc.id, created_at: now, updated_at: now });
      }
    }
    
    await queryInterface.bulkInsert('favorites', favData);
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.bulkDelete('favorites', null, {});
  }
};
