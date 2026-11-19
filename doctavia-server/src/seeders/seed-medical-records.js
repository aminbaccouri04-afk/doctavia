'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    const now = new Date();
    const [profiles] = await queryInterface.sequelize.query("SELECT id FROM profiles WHERE relationship = 'Self'");
    
    const recordsData = [];
    for (let i = 0; i < profiles.length; i++) {
      if (i % 2 === 0) {
        recordsData.push({
          profile_id: profiles[i].id,
          file_name: i % 4 === 0 ? 'blood_test.pdf' : 'chest_xray.png',
          file_type: i % 4 === 0 ? 'application/pdf' : 'image/png',
          file_size: 1024 * (i + 1),
          file_url: 'https://example.com/demo-file.pdf',
          description: i % 4 === 0 ? 'Annual blood work report' : 'Chest imaging from last visit',
          created_at: now,
          updated_at: now
        });
      }
    }
    
    await queryInterface.bulkInsert('medical_records', recordsData);
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.bulkDelete('medical_records', null, {});
  }
};
